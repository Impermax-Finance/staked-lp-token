pragma solidity >=0.5.0;

// For:
// SushiSwap
// ApeSwap
// PangolinV2

interface IMasterChef0212 {
	function lpToken(uint256) external view returns (address);
	function userInfo(uint256, address) external view returns (
		uint256 amount,
		uint256 rewardDebt
	);
	function poolInfo(uint256) external view returns (
		uint128 accSushiPerShare,
        uint64 lastRewardTime,
        uint64 allocPoint
	);
	function totalAllocPoint() external view returns (uint256);	
	function rewarder(uint256) external view returns (address);

	function deposit(uint256 _pid, uint256 _amount, address _to) external;
	function withdraw(uint256 _pid, uint256 _amount, address _to) external;
	function harvest(uint256 _pid, address _to) external;
}