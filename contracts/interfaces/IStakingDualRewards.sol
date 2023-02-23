pragma solidity >=0.5.0;

interface IStakingDualRewards {
	function rewardsTokenA() external view returns (address);
	function rewardsTokenB() external view returns (address);
	function rewardRateA() external view returns (uint256);
	function rewardRateB() external view returns (uint256);
	function stakingToken() external view returns (address);
	function balanceOf(address account) external view returns (uint256);

	function stake(uint256 amount) external;
	function withdraw(uint256 amount) external;
	function getReward() external;
}