pragma solidity >=0.5.0;

// For:
// MerchantJoe

interface IMasterChef0232 {
    function getToken(uint256 pid) external view returns (address);

    function getExtraRewarder(uint256 pid) external view returns (address);

    function getDeposit(
        uint256 pid,
        address account
    ) external view returns (uint256);

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function claim(uint256[] calldata pids) external;
}

interface IExtraRewarder {
    function getRewarderParameter()
        external
        view
        returns (
            address token,
            uint256 rewardPerSecond,
            uint256 lastUpdateTimestamp,
            uint256 endTimestamp
        );
}
