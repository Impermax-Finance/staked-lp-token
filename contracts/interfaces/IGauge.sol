pragma solidity >=0.5.0;


interface IGauge {
	function totalSupply() external view returns (uint);
	function rewardRate(address rewardToken) external view returns (uint256);
}