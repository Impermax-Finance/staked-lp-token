pragma solidity >=0.5.0;

interface ISolidlyMAGauge {
    function notifyRewardAmount(address token, uint amount) external;
    function getReward(uint256 _tokenId) external;
    function claimFees() external returns (uint claimed0, uint claimed1);
    function left(address token) external view returns (uint);
    function isForPair() external view returns (bool);
    function earned(uint256 _tokenId) external view returns (uint);
    function balanceOfToken(uint256 tokenId) external view returns (uint256);
    function deposit(uint256 amount) external returns (uint256 _tokenId);
    function withdrawAndHarvest(uint256 _tokenId) external;
    function rewardRate() external view returns (uint256);
    function totalWeight() external view returns (uint256 _totalWeight);
}