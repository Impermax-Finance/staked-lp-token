pragma solidity >=0.5.0;

interface IBaseV1Factory {
    function getPair(address tokenA, address tokenB, bool stable) external view returns (address pair);
    function getPool(address tokenA, address tokenB, bool stable) external view returns (address pair);
}
