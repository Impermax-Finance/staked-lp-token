pragma solidity >=0.5.0;

// For:
// SpookySwap
// DinoSwap
// SpiritSwap
// QiDao
// PlutusDAO
// SwapFish
// ZyberSwap

interface IMasterChef0221 {
	function poolInfo(uint256) external view returns (
		address lpToken, 
		uint256 allocPoint,
        uint256 lastRewardBlock,
        uint256 accRewardTokenPerShare
	);
	function userInfo(uint256, address) external view returns (
		uint256 amount,
		uint256 rewardDebt
	);
	function totalAllocPoint() external view returns (uint256);

	function deposit(uint256 _pid, uint256 _amount) external;
	function withdraw(uint256 _pid, uint256 _amount) external;
}