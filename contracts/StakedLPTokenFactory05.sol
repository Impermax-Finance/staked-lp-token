pragma solidity =0.5.16;

import "./StakedLPToken05.sol";
import "./interfaces/IStakingRewards05.sol";
import "./interfaces/IUniswapV2Pair.sol";

contract StakedLPTokenFactory05 {
	address public router;
	address public WETH;

	mapping(address => address) public getStakedLPToken;
	address[] public allStakedLPToken;

	event StakedLPTokenCreated(address indexed token0, address indexed token1, address indexed stakingRewards, address stakedLPToken, uint);

	constructor(address _router, address _WETH) public {
		router = _router;
		WETH = _WETH;
	}

	function allStakedLPTokenLength() external view returns (uint) {
		return allStakedLPToken.length;
	}

	function createStakedLPToken(address stakingRewards) external returns (address stakedLPToken) {
		require(getStakedLPToken[stakingRewards] == address(0), "StakedLPTokenFactory: STAKING_REWARDS_EXISTS");
		address pair = IStakingRewards05(stakingRewards).stakingToken();
		address rewardsTokenA = IStakingRewards05(stakingRewards).rewardsTokenDPX();
		address rewardsTokenB = IStakingRewards05(stakingRewards).rewardsTokenRDPX();
		address token0 = IUniswapV2Pair(pair).token0();
		address token1 = IUniswapV2Pair(pair).token1();
		bytes memory bytecode = type(StakedLPToken05).creationCode;
		assembly {
			stakedLPToken := create2(0, add(bytecode, 32), mload(bytecode), stakingRewards)
		}
		StakedLPToken05(stakedLPToken)._initialize(stakingRewards, pair, rewardsTokenA, rewardsTokenB, token0, token1, router, WETH);
		getStakedLPToken[stakingRewards] = stakedLPToken;
		allStakedLPToken.push(stakedLPToken);
		emit StakedLPTokenCreated(token0, token1, stakingRewards, stakedLPToken, allStakedLPToken.length);
	}
}
