pragma solidity =0.5.16;

import "./StakedLPTokenSolidlyBase3.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Router01.sol";

// updated codebase for thena v2 and pearl

contract StakedLPTokenFactorySolidlyBase3 {
	address public router;
	address public voter;
	address public rewardsToken;
	address[] public bridgeTokens;

	mapping(address => address) public getStakedLPToken;
	address[] public allStakedLPToken;

	event StakedLPTokenCreated(address indexed token0, address indexed token1, address indexed pair, address stakedLPToken, uint);

	constructor(address _router, address _voter, address _rewardsToken, address[] memory _bridgeTokens) public {
		router = _router;
		voter = _voter;
		rewardsToken = _rewardsToken;
		bridgeTokens = _bridgeTokens;
	}

	function allStakedLPTokenLength() external view returns (uint) {
		return allStakedLPToken.length;
	}

	function createStakedLPToken(address pair) external returns (address stakedLPToken) {
		require(getStakedLPToken[pair] == address(0), "StakedLPTokenFactory: POOL_EXISTS");
		require(!IBaseV1Pair(pair).stable(), "StakedLPTokenFactory: STABLE_PAIR");		
		address token0 = IUniswapV2Pair(pair).token0();
		address token1 = IUniswapV2Pair(pair).token1();
		bytes memory bytecode = type(StakedLPTokenSolidlyBase3).creationCode;
		assembly {
			stakedLPToken := create2(0, add(bytecode, 32), mload(bytecode), pair)
		}
		StakedLPTokenSolidlyBase3(stakedLPToken)._initialize(pair, token0, token1, router, voter, rewardsToken, bridgeTokens);
		getStakedLPToken[pair] = stakedLPToken;
		allStakedLPToken.push(stakedLPToken);
		emit StakedLPTokenCreated(token0, token1, pair, stakedLPToken, allStakedLPToken.length);
	}
}
