pragma solidity =0.5.16;

import "./PoolToken.sol";
import "./interfaces/IBaseV1Pair.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./libraries/SafeToken.sol";

contract StakedLPToken091 is PoolToken {
	using SafeToken for address;
	
	bool public constant isStakedLPToken = true;
	string public constant stakedLPTokenType = "091";
	bool public constant stable = false;
	
	address public token0;
	address public token1;
		
	function _initialize(
		address _underlying,
		address _token0,
		address _token1
	) external {
		require(factory == address(0), "StakedLPToken: FACTORY_ALREADY_SET"); // sufficient check
		factory = msg.sender;
		_setName("Staked Uniswap V2", "STKD-UNI-V2");
		underlying = _underlying;
		token0 = _token0;
		token1 = _token1;
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