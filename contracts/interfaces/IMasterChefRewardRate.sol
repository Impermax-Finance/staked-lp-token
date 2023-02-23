pragma solidity >=0.5.0;

interface IMasterChefRewardRate {
	function sushiPerSecond() external view returns (uint256);	
	function rewardPerSecond() external view returns (uint256);	
	function rewardsPerSecond() external view returns (uint256);	
	function bananaPerSecond() external view returns (uint256);
	function booPerSecond() external view returns (uint256);	
	function joePerSec() external view returns (uint256);
	function solarPerSec() external view returns (uint256);
	function thorusPerSecond() external view returns (uint256);
	function plsPerSecond() external view returns (uint256);
	function cakePerSecond() external view returns (uint256);	
	function zyberPerSec() external view returns (uint256);	
	
	function rewardPerBlock() external view returns (uint256);	
	function rewardsPerBlock() external view returns (uint256);	
	function cakePerBlock() external view returns (uint256);	
	function dinoPerBlock() external view returns (uint256);	
	function tribalChiefTribePerBlock() external view returns (uint256);	
	function snowballPerBlock() external view returns (uint256);	
	function spiritPerBlock() external view returns (uint256);
	function crystalPerBlock() external view returns (uint256);
	function hairPerBlock() external view returns (uint256);
	function cntPerBlock() external view returns (uint256);
	function solarPerBlock() external view returns (uint256);
}