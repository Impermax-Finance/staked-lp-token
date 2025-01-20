pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

interface IBaseV1Router02 {
    struct Route {
        address from;
        address to;
        bool stable;
    }

    function wftm() external pure returns (address);
    function factory() external pure returns (address);
    function defaultFactory() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] calldata routes,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}
