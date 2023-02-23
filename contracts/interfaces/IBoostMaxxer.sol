pragma solidity >=0.5.0;


interface IBoostMaxxer {
	function baseToken() external view returns (address);
	function userDepositedAmountInfo(address pool, address account) external view returns (uint256 amount);

	function deposit(address pool, uint256 amount) external;
	function withdraw(address pool, uint256 amount) external;
}