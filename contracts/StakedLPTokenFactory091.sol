pragma solidity =0.5.16;

import "./StakedLPToken091.sol";
import "./interfaces/IBaseV1Pair.sol";

contract StakedLPTokenFactory091 {
	mapping(address => address) public getStakedLPToken;
	address[] public allStakedLPToken;

	event StakedLPTokenCreated(address indexed token0, address indexed token1, address indexed pair, address stakedLPToken, uint);

	constructor() public {
	}

	function allStakedLPTokenLength() external view returns (uint) {
		return allStakedLPToken.length;
	}

	function createStakedLPToken(address pair) external returns (address stakedLPToken) {
		require(getStakedLPToken[pair] == address(0), "StakedLPTokenFactory: PAIR_EXISTS");
		require(!IBaseV1Pair(pair).stable(), "StakedLPTokenFactory: STABLE_PAIR");		
		address token0 = IBaseV1Pair(pair).token0();
		address token1 = IBaseV1Pair(pair).token1();
		bytes memory bytecode = type(StakedLPToken091).creationCode;
		assembly {
			stakedLPToken := create2(0, add(bytecode, 32), mload(bytecode), pair)
		}
		StakedLPToken091(stakedLPToken)._initialize(pair, token0, token1);
		getStakedLPToken[pair] = stakedLPToken;
		allStakedLPToken.push(stakedLPToken);
		emit StakedLPTokenCreated(token0, token1, pair, stakedLPToken, allStakedLPToken.length);
	}
}
