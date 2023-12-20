pragma solidity ^0.8.19;

interface IWrapper {
  function getAmountOut(address tokenIn, uint256 amountIn, address tokenOut) external view returns (uint256 amountOut);
}
