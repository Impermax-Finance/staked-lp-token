pragma solidity >=0.5.0;

// For:
// TraderJoeV3

interface IMasterChef023 {
	function poolInfo(uint256) external view returns (
		address lpToken, 
		uint256 accRewardTokenPerShare,
		uint256 lastRewardBlock,
		uint256 allocPoint,
		address rewarder 
	);
	function userInfo(uint256, address) external view returns (
		uint256 amount,
		uint256 rewardDebt
	);
	function totalAllocPoint() external view returns (uint256);

	function deposit(uint256 _pid, uint256 _amount) external;
	function withdraw(uint256 _pid, uint256 _amount) external;
}