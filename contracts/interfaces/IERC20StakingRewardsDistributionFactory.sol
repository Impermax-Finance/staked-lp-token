pragma solidity >=0.5.0;

// For: https://github.com/luzzif/erc20-staking-rewards-distribution-contracts/blob/master/contracts/ERC20StakingRewardsDistribution.sol

interface IERC20StakingRewardsDistributionFactory {
    function getDistributionsAmount() external view returns (uint256);
    function distributions(uint256) external view returns (address);
}