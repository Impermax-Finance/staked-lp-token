pragma solidity >=0.5.0;

// For: Radiant

interface IMasterChef025 {
	function registeredTokens(uint256) external view returns (address);
	function userInfo(address, address) external view returns (
		uint256 amount,
		uint256 rewardDebt
	);
	function poolInfo(address) external view returns (
		uint256 allocPoint,
        uint256 lastRewardTime,
        uint256 accRewardPerShare
	);
	function totalAllocPoint() external view returns (uint256);

	function deposit(address _token, uint256 _amount) external;
	function withdraw(address _token, uint256 _amount) external;
	function claim(address _user, address[] calldata _tokens) external;
	
	function rewardMinter() external view returns (address);
}