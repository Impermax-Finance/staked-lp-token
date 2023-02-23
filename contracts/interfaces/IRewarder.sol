pragma solidity >=0.5.0;

interface IRewarder {
	function pendingTokens(uint256 pid, address user, uint256 sushiAmount) external view returns (address[] memory, uint256[] memory);
}