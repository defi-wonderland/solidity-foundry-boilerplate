pragma solidity ^0.8.19;

import {IWrapper} from '../../../../interfaces/Oracle/IWrapper.sol';
import {IUniswapV2Router02} from '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import {IUniswapV2Pair} from '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import {IUniswapV2Factory} from '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';

contract SushiWrapper is IWrapper {
  IUniswapV2Router02 constant router = IUniswapV2Router02(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
  IUniswapV2Factory constant factory = IUniswapV2Factory(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac);

  constructor() {}

  function getAmountOut(
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut
  ) public view returns (uint256 _amountOut) {
    // need to sort tokens in the correct order
    // generating pair address as outlined here:
    (address _token0, address _token1) = _tokenIn < _tokenOut ? (_tokenIn, _tokenOut) : (_tokenOut, _tokenIn);
    address _pairAddress = factory.getPair(_token0, _token1);
    IUniswapV2Pair _pair = IUniswapV2Pair(_pairAddress);
    (uint256 _reserve0, uint256 _reserve1,) = _pair.getReserves();

    if (_tokenIn == _pair.token0()) {
      _amountOut = router.getAmountOut(_amountIn, _reserve0, _reserve1);
    } else {
      _amountOut = router.getAmountOut(_amountIn, _reserve1, _reserve0);
    }
  }

  function getAmountOut(
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut,
    uint32 _timeAgo
  ) public view returns (uint256 _amountOut) {
    _amountOut = getAmountOut(_tokenIn, _amountIn, _tokenOut);
  }
}
