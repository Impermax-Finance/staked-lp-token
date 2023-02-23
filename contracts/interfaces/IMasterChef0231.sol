pragma solidity >=0.5.0;

// For:
// TraderJoe

interface IMasterChef0231 {
	function poolInfo(uint256) external view returns (
		address lpToken, 
		uint256 allocPoint,
		uint256 accRewardTokenPerShare,
		uint256 accRewardTokenPerFactorPerShare,
		uint256 lastRewardBlock,
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