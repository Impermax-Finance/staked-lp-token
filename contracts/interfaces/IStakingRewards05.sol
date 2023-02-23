pragma solidity >=0.5.0;

interface IStakingRewards05 {
    function rewardsTokenDPX() external view returns (address);
    function rewardsTokenRDPX() external view returns (address);
    function rewardRateDPX() external view returns (address);
    function rewardRateRDPX() external view returns (address);
    function stakingToken() external view returns (address);
    function balanceOf(address account) external view returns (uint256);

    function stake(uint256 amount) external payable;
    function withdraw(uint256 amount) external;
    function getReward(uint256 rewardsTokenID) external;
}