pragma solidity =0.5.16;

import "./StakedLPToken0222.sol";
import "./interfaces/IMasterChef0222.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Router01.sol";

contract StakedLPTokenFactory0222 {
	address public router;
	address public masterChef;
	address public rewardsToken;
	address public WETH;

	mapping(uint256 => address) public getStakedLPToken;
	address[] public allStakedLPToken;

	event StakedLPTokenCreated(address indexed token0, address indexed token1, uint256 indexed pid, address stakedLPToken, uint);

	constructor(address _router, address _masterChef, address _rewardsToken) public {
		router = _router;
		masterChef = _masterChef;
		rewardsToken = _rewardsToken;
		WETH = IUniswapV2Router01(_router).WETH();
	}

	function allStakedLPTokenLength() external view returns (uint) {
		return allStakedLPToken.length;
	}

	function createStakedLPToken(uint256 pid) external returns (address stakedLPToken) {
		require(getStakedLPToken[pid] == address(0), "StakedLPTokenFactory: PID_EXISTS");
		(address pair,,,) = IMasterChef0222(masterChef).poolInfo(pid);
		address token0 = IUniswapV2Pair(pair).token0();
		address token1 = IUniswapV2Pair(pair).token1();
		bytes memory bytecode = type(StakedLPToken0222).creationCode;
		assembly {
			stakedLPToken := create2(0, add(bytecode, 32), mload(bytecode), pid)
		}
		StakedLPToken0222(stakedLPToken)._initialize(pid, pair, token0, token1, router, masterChef, rewardsToken, WETH);
		getStakedLPToken[pid] = stakedLPToken;
		allStakedLPToken.push(stakedLPToken);
		emit StakedLPTokenCreated(token0, token1, pid, stakedLPToken, allStakedLPToken.length);
	}
}
