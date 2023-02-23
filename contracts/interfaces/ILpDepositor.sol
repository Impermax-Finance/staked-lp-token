pragma solidity >=0.5.0;


interface ILpDepositor {
	function SOLID() external view returns (address);
	function SEX() external view returns (address);
	function userBalances(address account, address pool) external view returns (uint256 amount);
	function gaugeForPool(address pool) external view returns (address);

	function deposit(address pool, uint256 amount) external;
	function withdraw(address pool, uint256 amount) external;
	function getReward(address[] calldata pools) external;
}