pragma solidity >=0.5.0;

interface IOxLens {
    function stakingRewardsBySolidPool(address solidPoolAddress)
        external
        view
        returns (address);
        
    function userProxyByAccount(address accountAddress)
        external
        view
        returns (address);
}