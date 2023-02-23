pragma solidity >=0.5.0;

interface IStakedLPTokenFactory02 {
	
	event StakedLPTokenCreated(address indexed token0, address indexed token1, uint256 indexed pid, address stakedLPToken, uint);

	function router() external view returns (address);
	function masterChef() external view returns (address);
	function rewardsToken() external view returns (address);
	function WETH() external view returns (address);
	function getStakedLPToken(uint) external view returns (address);
	function allStakedLPToken(uint) external view returns (address);
	function allStakedLPTokenLength() external view returns (uint);
	
	function createStakedLPToken(uint256 pid) external returns (address stakedLPToken);
	
}