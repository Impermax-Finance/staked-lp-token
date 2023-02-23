pragma solidity >=0.5.0;

// For TetuSwap

interface IStakingRewards08 {
    function rewardTokens() external view returns (address[] memory);
    function rewardRateForToken(address) external view returns (uint256);
    function underlying() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function underlyingBalanceWithInvestment() external view returns (uint256);

    function deposit(uint256 amount) external;
    function withdraw(uint256 numberOfShares) external;
    function getReward(address rewardToken) external;
}