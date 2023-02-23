pragma solidity >=0.5.0;

interface IOxMultiRewards {
    function rewardData(address)
        external
        view
        returns (
            address rewardsDistributor,
            uint256 rewardsDuration,
            uint256 periodFinish,
            uint256 rewardRate,
            uint256 lastUpdateTime,
            uint256 rewardPerTokenStored
        );

    function balanceOf(address) external view returns (uint256);

    function totalSupply() external view returns (uint256);
}