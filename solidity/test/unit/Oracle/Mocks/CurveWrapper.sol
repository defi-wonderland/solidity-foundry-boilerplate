pragma solidity ^0.8.19;

import {ICurveFactory} from './Interfaces/ICurveFactory.sol';
import {IStableSwap} from './Interfaces/IStableSwap.sol';
import {IWrapper} from '../../../../interfaces/Oracle/IWrapper.sol';

contract CurveWrapper is IWrapper {
  address constant factory = 0xB9fC157394Af804a3578134A6585C0dc9cc990d4;

  constructor() {}

  function getAmountOut(
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut
  ) public view returns (uint256 _amountOut) {
    IStableSwap _pool = IStableSwap(getPool(_tokenIn, _tokenOut));
    uint256 _i;
    uint256 _j;

    // Assumption is _tokenIn and _tokenOut are both in the coins list
    // This holds true as long as the pool was derived from these addresses, so the pool must contain them
    while (_pool.coins(_i) != _tokenIn) {
      ++_i;
    }

    while (_pool.coins(_j) != _tokenOut) {
      ++_j;
    }

    _amountOut = _pool.get_dy(int128(int256(_i)), int128(int256(_j)), _amountIn);
  }

  function getPool(address _tokenIn, address _tokenOut) public view returns (address _pool) {
    _pool = ICurveFactory(factory).find_pool_for_coins(_tokenIn, _tokenOut);

    if (_pool == address(0)) revert InvalidPair();
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
