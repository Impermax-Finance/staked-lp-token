pragma solidity >=0.5.0;

// For BENQI

interface IStakingRewards06 {
    function rewardTokenAddresses(uint256) external view returns (address);
    function rewardSpeeds(uint256) external view returns (uint256);
    function pglTokenAddress() external view returns (address);
    function supplyAmount(address account) external view returns (uint256);

    function deposit(uint256 amount) external;
    function redeem(uint256 amount) external;
    function claimRewards() external;
}