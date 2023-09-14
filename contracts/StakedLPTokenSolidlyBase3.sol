pragma solidity =0.5.16;

import "./PoolToken.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IBaseV1Router01.sol";
import "./interfaces/IBaseV1Pair.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IBaseV1Factory.sol";
import "./interfaces/ISolidlyVoter.sol";
import "./interfaces/ISolidlyGauge3.sol";
import "./libraries/SafeToken.sol";
import "./libraries/Math.sol";

// updated codebase for thena v2 and pearl

contract StakedLPTokenSolidlyBase3 is PoolToken {
	using SafeToken for address;
	
	bool public constant isStakedLPToken = true;
	string public constant stakedLPTokenType = "SolidlyBase3";
	bool public constant stable = false;
	
	address public token0;
	address public token1;
	address public router;
	address public gauge;
	address public rewardsToken;
	address[] public bridgeTokens;
	uint256 public constant REINVEST_BOUNTY = 0.02e18;

	event Reinvest(address indexed caller, uint256 reward, uint256 bounty);
		
	function _initialize(
		address _underlying,
		address _token0,
		address _token1,
		address _router,
		address _voter,
		address _rewardsToken,
		address[] calldata _bridgeTokens
	) external {
		require(factory == address(0), "StakedLPToken: FACTORY_ALREADY_SET"); // sufficient check
		factory = msg.sender;
		_setName("Staked Uniswap V2", "STKD-UNI-V2");
		underlying = _underlying;
		token0 = _token0;
		token1 = _token1;
		router = _router;
		gauge = ISolidlyVoter(_voter).gauges(_underlying);
		require(gauge != address(0), "StakedLPToken: NO_GAUGE");
		rewardsToken = _rewardsToken;
		bridgeTokens = _bridgeTokens;
		_rewardsToken.safeApprove(address(_router), uint256(-1));
		_underlying.safeApprove(address(gauge), uint256(-1));
		for (uint i = 0; i < _bridgeTokens.length; i++) {
			_bridgeTokens[i].safeApprove(address(_router), uint256(-1));
		}
	}
	
	/*** PoolToken Overrides ***/
	
	function _update() internal {
		uint256 _totalBalance = ISolidlyGauge3(gauge).balanceOf(address(this));
		totalBalance = _totalBalance;
		emit Sync(_totalBalance);
	}
	
	// this low-level function should be called from another contract
	function mint(address minter) external nonReentrant update returns (uint mintTokens) {
		uint mintAmount = underlying.myBalance();
		// handle pools with deposit fees by checking balance before and after deposit
		uint256 _totalBalanceBefore = ISolidlyGauge3(gauge).balanceOf(address(this));
		ISolidlyGauge3(gauge).deposit(mintAmount);
		uint256 _totalBalanceAfter = ISolidlyGauge3(gauge).balanceOf(address(this));
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
		ISolidlyGauge3(gauge).withdraw(redeemAmount);
		_safeTransfer(redeemer, redeemAmount);
		emit Redeem(msg.sender, redeemer, redeemAmount, redeemTokens);		
	}
	
	/*** Reinvest ***/
	
	function _optimalDepositA(uint256 amountA, uint256 reserveA) internal pure returns (uint256) {
		uint256 a = uint256(1997).mul(reserveA);
		uint256 b = amountA.mul(1000).mul(reserveA).mul(3988);
		uint256 c = Math.sqrt(a.mul(a).add(b));
		return c.sub(a).div(1994);
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
		ISolidlyGauge3(gauge).getReward();
		return rewardsToken.myBalance();
	}
	
	function getReward() external nonReentrant returns (uint256) {
		require(msg.sender == tx.origin);
		return _getReward();
	}

	function _swapWithBestBridge() internal view returns (address bestBridgeToken, uint bestIndex) {
		for (uint i = 0; i < bridgeTokens.length; i++) {
			if (token0 == bridgeTokens[i]) return (bridgeTokens[i], 0);
			if (token1 == bridgeTokens[i]) return (bridgeTokens[i], 1);
		}
		(uint256 r0, uint256 r1,) = IUniswapV2Pair(underlying).getReserves();
		address[2] memory tokens = [token0, token1];
		uint[2] memory reserves = [r0, r1];
		bestBridgeToken = bridgeTokens[0];
		bestIndex = 0;
		uint bestLiquidity = 0;
		address pairFactory = IBaseV1Router01(router).factory();
		for (uint i = 0; i < bridgeTokens.length; i++) {
			for (uint j = 0; j < 2; j++) {
				address pair = IBaseV1Factory(pairFactory).getPair(tokens[j], bridgeTokens[i], false);
				if (pair == address(0)) continue;
				uint liquidity = tokens[j].balanceOf(pair).mul(1e18).div(reserves[j]);
				if (liquidity > bestLiquidity) {
					bestLiquidity = liquidity;
					bestIndex = j;
					bestBridgeToken = bridgeTokens[i];
				}
			}
		}
		return (bestBridgeToken, bestIndex);
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
			(address bridgeToken, uint index) = _swapWithBestBridge();
			swapExactTokensForTokens(rewardsToken, bridgeToken, reward.sub(bounty));
			if (token0 == bridgeToken || token1 == bridgeToken) { 
				(tokenA, tokenB) = token0 == bridgeToken ? (token0, token1) : (token1, token0);
			}
			else {
				swapExactTokensForTokens(bridgeToken, index == 0 ? token0 : token1, bridgeToken.myBalance());
				(tokenA, tokenB) = index == 0 ? (token0, token1) : (token1, token0);
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
		ISolidlyGauge3(gauge).deposit(liquidity);
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