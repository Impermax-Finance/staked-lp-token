pragma solidity =0.5.16;

import "./StakedLPToken10.sol";
import "./interfaces/IBoostMaxxer.sol";
import "./interfaces/IBaseV1Pair.sol";
import "./interfaces/IBaseV1Router01.sol";

contract StakedLPTokenFactory10 {
	address public router;
	address public lpDepositor;
	address public rewardsToken;
	address public WETH;

	mapping(address => address) public getStakedLPToken;
	address[] public allStakedLPToken;

	event StakedLPTokenCreated(address indexed token0, address indexed token1, address indexed pair, address stakedLPToken, uint);

	constructor(address _router, address _lpDepositor) public {
		router = _router;
		lpDepositor = _lpDepositor;
		rewardsToken = IBoostMaxxer(_lpDepositor).baseToken();
		WETH = IBaseV1Router01(_router).wftm();
	}

	function allStakedLPTokenLength() external view returns (uint) {
		return allStakedLPToken.length;
	}

	function createStakedLPToken(address pair) external returns (address payable stakedLPToken) {
		require(getStakedLPToken[pair] == address(0), "StakedLPTokenFactory: PAIR_EXISTS");
		require(!IBaseV1Pair(pair).stable(), "StakedLPTokenFactory: STABLE_PAIR");		
		address token0 = IBaseV1Pair(pair).token0();
		address token1 = IBaseV1Pair(pair).token1();
		bytes memory bytecode = type(StakedLPToken10).creationCode;
		assembly {
			stakedLPToken := create2(0, add(bytecode, 32), mload(bytecode), pair)
		}
		StakedLPToken10(stakedLPToken)._initialize(pair, token0, token1, router, lpDepositor, rewardsToken, WETH);
		getStakedLPToken[pair] = stakedLPToken;
		allStakedLPToken.push(stakedLPToken);
		emit StakedLPTokenCreated(token0, token1, pair, stakedLPToken, allStakedLPToken.length);
	}
}
