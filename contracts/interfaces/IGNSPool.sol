pragma solidity >=0.5.0;

interface IGNSPool {
    function rewardsToken() external view returns (address);
    function lp() external view returns (address);
    function users(address account) external view returns (
        uint provided,
        uint debtToken,
        uint debtQuick,
        uint stakedNftsCount,
        uint totalBoost,
        address referral,
        uint referralRewardsToken
    );

    function stake(uint256 amount, address referral) external;
    function unstake(uint256 amount) external;
    function harvest() external;
}