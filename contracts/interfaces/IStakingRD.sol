pragma solidity >=0.5.0;

// For: https://github.com/luzzif/erc20-staking-rewards-distribution-contracts/blob/master/contracts/ERC20StakingRewardsDistribution.sol

interface IStakingRD {
    function rewards(uint256) external view returns (
		address token,
		uint256 amount,
		uint256 perStakedToken,
		uint256 recoverableSeconds,
		uint256 claimed
	);
    function stakableToken() external view returns (address);
    function factory() external view returns (address);
    function initialized() external view returns (bool);
    function canceled() external view returns (bool);
    function locked() external view returns (bool);
    function stakingCap() external view returns (uint256);
    function startingTimestamp() external view returns (uint256);
    function endingTimestamp() external view returns (uint256);
    function totalStakedTokensAmount() external view returns (uint256);
    function stakedTokensOf(address account) external view returns (uint256);
    function earnedRewardsOf(address account) external view returns (uint256[] memory);

    function stake(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function claimAll(address recipient) external;
}