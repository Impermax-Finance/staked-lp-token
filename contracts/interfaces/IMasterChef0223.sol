pragma solidity >=0.5.0;

// For:
// ArbiDex

interface IMasterChef0223 {
	function poolInfo(uint256) external view returns (
		address lpToken,
		uint256 arxAllocPoint,
		uint256 WETHAllocPoint,
        uint256 lastRewardTime,
        uint256 accArxPerShare,
        uint256 accWETHPerShare,
        uint256 totalDeposit
	);
	function userInfo(uint256, address) external view returns (
		uint256 amount,
		uint256 arxRewardDebt,
		uint256 WETHRewardDebt
	);
	function arxTotalAllocPoint() external view returns (uint256);
	function WETHTotalAllocPoint() external view returns (uint256);
	function arxPerSec() external view returns (uint256);	
	function WETHPerSec() external view returns (uint256);	
	function arx() external view returns (address);	
	function WETH() external view returns (address);	

	function deposit(uint256 _pid, uint256 _amount) external;
	function withdraw(uint256 _pid, uint256 _amount) external;
}