pragma solidity >=0.5.0;

interface ISolidlyGauge8 {
    function notifyRewardAmount(address token, uint amount) external;
    function getReward(address account, address[] calldata tokens) external;
    function claimFees() external returns (uint claimed0, uint claimed1);
    function left(address token) external view returns (uint);
    function isForPair() external view returns (bool);
    function earned(address account) external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function rewardRate() external view returns (uint);
    function deposit(uint256 amount,uint256 tokenId) external;
    function withdraw(uint256 amount) external;
}