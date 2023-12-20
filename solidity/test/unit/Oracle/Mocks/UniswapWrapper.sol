pragma solidity ^0.8.19;

import {IWrapper} from '../../../../interfaces/Oracle/IWrapper.sol';
import {IUniswapV2Router02} from '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import {IUniswapV2Pair} from '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';

contract UniswapWrapper is IWrapper {
  IUniswapV2Router02 constant router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
  address constant factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

  constructor() {}

  function getAmountOut(
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut
  ) public view returns (uint256 _amountOut) {
    // need to sort tokens in the correct order
    // generating pair address as outlined here:
    (address _token0, address _token1) = _tokenIn < _tokenOut ? (_tokenIn, _tokenOut) : (_tokenOut, _tokenIn);
    address _pairAddress = address(
      uint160(
        uint256(
          keccak256(
            abi.encodePacked(
              hex'ff',
              factory,
              keccak256(abi.encodePacked(_token0, _token1)),
              hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f'
            )
          )
        )
      )
    );

    if (_pairAddress == address(0)) {
      revert InvalidPair();
    }
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
