pragma solidity =0.5.16;

import "./PoolToken.sol";
import "./interfaces/IBoostMaxxer.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IBaseV1Router01.sol";
import "./interfaces/IBaseV1Pair.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IWETH.sol";
import "./libraries/SafeToken.sol";
import "./libraries/Math.sol";

contract StakedLPToken10 is PoolToken {
	using SafeToken for address;
	
	bool public constant isStakedLPToken = true;
	string public constant stakedLPTokenType = "10";
	bool public constant stable = false;
	
	address public token0;
	address public token1;
	address public router;
	address public lpDepositor;
	address public rewardsToken;
	address public WETH;
	uint256 public constant REINVEST_BOUNTY = 0.01e18;

	event Reinvest(address indexed caller, uint256 reward, uint256 bounty);
		
	function _initialize(
		address _underlying,
		address _token0,
		address _token1,
		address _router,
		address _lpDepositor,
		address _rewardsToken,
		address _WETH
	) external {
		require(factory == address(0), "StakedLPToken: FACTORY_ALREADY_SET"); // sufficient check
		factory = msg.sender;
		_setName("Staked Uniswap V2", "STKD-UNI-V2");
		underlying = _underlying;
		token0 = _token0;
		token1 = _token1;
		router = _router;
		lpDepositor = _lpDepositor;
		rewardsToken = _rewardsToken;
		WETH = _WETH;
		_rewardsToken.safeApprove(address(_router), uint256(-1));
		_WETH.safeApprove(address(_router), uint256(-1));
		_underlying.safeApprove(address(_lpDepositor), uint256(-1));
	}
	
	function () external payable {
		uint256 balance = address(this).balance;
		IWETH(WETH).deposit.value(balance)();
	}
	
	/*** PoolToken Overrides ***/
	
	function _update() internal {
		uint256 _totalBalance = IBoostMaxxer(lpDepositor).userDepositedAmountInfo(underlying, address(this));
		totalBalance = _totalBalance;
		emit Sync(_totalBalance);
	}
	
	// this low-level function should be called from another contract
	function mint(address minter) external nonReentrant update returns (uint mintTokens) {
		uint mintAmount = underlying.myBalance();
		// handle pools with deposit fees by checking balance before and after deposit
		uint256 _totalBalanceBefore = IBoostMaxxer(lpDepositor).userDepositedAmountInfo(underlying, address(this));
		IBoostMaxxer(lpDepositor).deposit(underlying, mintAmount);
		uint256 _totalBalanceAfter = IBoostMaxxer(lpDepositor).userDepositedAmountInfo(underlying, address(this));
		mintTokens = _totalBalanceAfter.sub(_totalBalanceBefore).mul(1e18).div(exchangeRate());

		if(totalSupply == 0) {
			// permanently lock the first MINIMUM_LIQUIDITY tokens
			mintTokens = mintTokens.sub(MINIMUM_LIQUIDITY);
			_mint(address(0), MINIMUM_LIQUIDITY);
		}
		require(mintTokens > 0, "StakedLPToken: MINT_AMOUNT_ZERO");
		_mint(minter, mintTokens);
		emit Mint(msg.sender, minter, mintAmount, mintTokens);
	}

	// this low-level function should be called from another contract
	function redeem(address redeemer) external nonReentrant update returns (uint redeemAmount) {
		uint redeemTokens = balanceOf[address(this)];
		redeemAmount = redeemTokens.mul(exchangeRate()).div(1e18);

		require(redeemAmount > 0, "StakedLPToken: REDEEM_AMOUNT_ZERO");
		require(redeemAmount <= totalBalance, "StakedLPToken: INSUFFICIENT_CASH");
		_burn(address(this), redeemTokens);
		IBoostMaxxer(lpDepositor).withdraw(underlying, redeemAmount);
		_safeTransfer(redeemer, redeemAmount);
		emit Redeem(msg.sender, redeemer, redeemAmount, redeemTokens);
	}
	
	/*** Reinvest ***/
	
	function _optimalDepositA(uint256 amountA, uint256 reserveA) internal pure returns (uint256) {
		uint256 a = uint256(1999).mul(reserveA);
		uint256 b = amountA.mul(1000).mul(reserveA).mul(3996);
		uint256 c = Math.sqrt(a.mul(a).add(b));
		return c.sub(a).div(1998);
	}
	
	function approveRouter(address token, uint256 amount) internal {
		if (IERC20(token).allowance(address(this), router) >= amount) return;
		token.safeApprove(address(router), uint256(-1));
	}
	
	function swapExactTokensForTokens(address tokenIn, address tokenOut, uint256 amount) internal {
		approveRouter(tokenIn, amount);
		IBaseV1Router01(router).swapExactTokensForTokensSimple(amount, 0, tokenIn, tokenOut, false, address(this), now);
	}
	
	function addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB) internal returns (uint256 liquidity) {
		approveRouter(tokenA, amountA);
		approveRouter(tokenB, amountB);
		(,,liquidity) = IBaseV1Router01(router).addLiquidity(tokenA, tokenB, false, amountA, amountB, 0, 0, address(this), now);
	}
	
	function _getReward() internal returns (uint256) {
		address[] memory pools = new address[](1);
		pools[0] = address(underlying);
		IBoostMaxxer(lpDepositor).withdraw(underlying, 0);
		
		return rewardsToken.myBalance();
	}
	
	function getReward() external nonReentrant returns (uint256) {
		require(msg.sender == tx.origin);
		return _getReward();
	}

	function reinvest() external nonReentrant update {
		require(msg.sender == tx.origin);
		// 1. Withdraw all the rewards.		
		uint256 reward = _getReward();
		if (reward == 0) return;
		// 2. Send the reward bounty to the caller.
		uint256 bounty = reward.mul(REINVEST_BOUNTY) / 1e18;
		rewardsToken.safeTransfer(msg.sender, bounty);
		// 3. Convert all the remaining rewards to token0 or token1.
		address tokenA;
		address tokenB;
		if (token0 == rewardsToken || token1 == rewardsToken) {
			(tokenA, tokenB) = token0 == rewardsToken ? (token0, token1) : (token1, token0);
		}
		else {
			swapExactTokensForTokens(rewardsToken, WETH, reward.sub(bounty));
			if (token0 == WETH || token1 == WETH) { 
				(tokenA, tokenB) = token0 == WETH ? (token0, token1) : (token1, token0);
			}
			else {
				swapExactTokensForTokens(WETH, token0, WETH.myBalance());
				(tokenA, tokenB) = (token0, token1);
			}
		}
		// 4. Convert tokenA to LP Token underlyings.
		uint256 totalAmountA = tokenA.myBalance();
		assert(totalAmountA > 0);
		(uint256 r0, uint256 r1,) = IUniswapV2Pair(underlying).getReserves();
		uint256 reserveA = tokenA == token0 ? r0 : r1;
		uint256 swapAmount = _optimalDepositA(totalAmountA, reserveA);
		swapExactTokensForTokens(tokenA, tokenB, swapAmount);
		uint256 liquidity = addLiquidity(tokenA, tokenB, totalAmountA.sub(swapAmount), tokenB.myBalance());
		// 5. Stake the LP Tokens. 
		IBoostMaxxer(lpDepositor).deposit(underlying, liquidity);
		emit Reinvest(msg.sender, reward, bounty);
	}
	
	/*** Mirrored From uniswapV2Pair ***/

	function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) {
		(uint _reserve0, uint _reserve1, uint _blockTimestampLast) = IUniswapV2Pair(underlying).getReserves();
		reserve0 = safe112(_reserve0);
		reserve1 = safe112(_reserve1);
		blockTimestampLast = uint32(_blockTimestampLast % 2**32);
		// if no token has been minted yet mirror uniswap getReserves
		if (totalSupply == 0) return (reserve0, reserve1, blockTimestampLast);
		// else, return the underlying reserves of this contract
		uint256 _totalBalance = totalBalance;
		uint256 _totalSupply = IUniswapV2Pair(underlying).totalSupply();
		reserve0 = safe112(_totalBalance.mul(reserve0).div(_totalSupply));
		reserve1 = safe112(_totalBalance.mul(reserve1).div(_totalSupply));
		require(reserve0 > 100 && reserve1 > 100, "StakedLPToken: INSUFFICIENT_RESERVES");
	}
	
	function observationLength() external view returns (uint) {
		return IBaseV1Pair(underlying).observationLength();
	}
    function observations(uint index) external view returns (
        uint timestamp,
        uint reserve0Cumulative,
        uint reserve1Cumulative
    ) {
		return IBaseV1Pair(underlying).observations(index);
	}
    function currentCumulativePrices() external view returns (
        uint reserve0Cumulative,
        uint reserve1Cumulative,
        uint timestamp
    ) {
		return IBaseV1Pair(underlying).currentCumulativePrices();
	}

	/*** Utilities ***/
	
	function safe112(uint n) internal pure returns (uint112) {
		require(n < 2**112, "StakedLPToken: SAFE112");
		return uint112(n);
	}
}