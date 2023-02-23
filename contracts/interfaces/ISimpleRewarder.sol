pragma solidity >=0.5.0;

interface ISimpleRewarder {
	function isNative() external pure returns (bool);
	function pendingTokens(address user) external view returns (uint256 pending);
	function rewardToken() external view returns (address);
	function tokenPerSec() external view returns (uint256);
}