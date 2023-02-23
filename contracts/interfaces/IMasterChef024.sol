pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

// For:
// SolarDistributorV2

interface IMasterChef024 {
	function poolInfo(uint256) external view returns (
		address lpToken, 
		uint256 allocPoint,
		uint256 lastRewardTimestamp,
		uint256 accRewardTokenPerShare,
		uint16 depositFeeBP,
		uint256 harvestInterval,
		uint256 totalLp
	);
	function userInfo(uint256, address) external view returns (
		uint256 amount,
		uint256 rewardDebt,
		uint256 rewardLockedUp,
        uint256 nextHarvestUntil
	);
	function totalAllocPoint() external view returns (uint256);
	
	function poolRewarders(uint256 _pid) external view returns (address[] memory rewarders);
	function poolRewardsPerSec(uint256 _pid) external view returns (
		address[] memory addresses,
		string[] memory symbols,
		uint256[] memory decimals,
		uint256[] memory rewardsPerSec
	);

	function deposit(uint256 _pid, uint256 _amount) external;
	function withdraw(uint256 _pid, uint256 _amount) external;
}