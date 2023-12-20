pragma solidity ^0.8.19;

import {IWrapper} from '../../../../interfaces/Oracle/IWrapper.sol';
import {IUniswapV3Pool} from '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import {IUniswapV3Factory} from '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@uniswap/v3-core/contracts/libraries/FullMath.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';

contract UniswapV3Wrapper is IWrapper {
  IUniswapV3Factory constant _factory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);

  constructor() {}

  function getAmountOut(
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut
  ) public view returns (uint256 _amountOut) {
    address _pool;

    // lowest fee pool found is the correct addresss
    if (_factory.getPool(_tokenIn, _tokenOut, 100) != address(0)) {
      _pool = _factory.getPool(_tokenIn, _tokenOut, 100);
    } else if (_factory.getPool(_tokenIn, _tokenOut, 500) != address(0)) {
      _pool = _factory.getPool(_tokenIn, _tokenOut, 500);
    } else if (_factory.getPool(_tokenIn, _tokenOut, 3000) != address(0)) {
      _pool = _factory.getPool(_tokenIn, _tokenOut, 3000);
    } else if (_factory.getPool(_tokenIn, _tokenOut, 10_000) != address(0)) {
      _pool = _factory.getPool(_tokenIn, _tokenOut, 10_000);
    } else {
      revert InvalidPair();
    }

    (int24 tick,) = consult(_pool, 1);
    _amountOut = getQuoteAtTick(tick, uint128(_amountIn), _tokenIn, _tokenOut);
  }

  function getAmountOut(
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut,
    uint32 _timeAgo
  ) public view returns (uint256 _amountOut) {
    address _pool;

    // lowest fee pool found is the correct addresss
    if (_factory.getPool(_tokenIn, _tokenOut, 100) != address(0)) {
      _pool = _factory.getPool(_tokenIn, _tokenOut, 100);
    } else if (_factory.getPool(_tokenIn, _tokenOut, 500) != address(0)) {
      _pool = _factory.getPool(_tokenIn, _tokenOut, 500);
    } else if (_factory.getPool(_tokenIn, _tokenOut, 3000) != address(0)) {
      _pool = _factory.getPool(_tokenIn, _tokenOut, 3000);
    } else if (_factory.getPool(_tokenIn, _tokenOut, 10_000) != address(0)) {
      _pool = _factory.getPool(_tokenIn, _tokenOut, 10_000);
    } else {
      revert InvalidPair();
    }

    (int24 tick,) = consult(_pool, _timeAgo);
    _amountOut = getQuoteAtTick(tick, uint128(_amountIn), _tokenIn, _tokenOut);
  }

  // pulled from OracleLibrary
  // Couldn't use library methods directly since it had solc version <0.8
  // Minor changes made with casting
  function consult(
    address pool,
    uint32 secondsAgo
  ) internal view returns (int24 arithmeticMeanTick, uint128 harmonicMeanLiquidity) {
    require(secondsAgo != 0, 'BP');

    uint32[] memory secondsAgos = new uint32[](2);
    secondsAgos[0] = secondsAgo;
    secondsAgos[1] = 0;

    (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) =
      IUniswapV3Pool(pool).observe(secondsAgos);

    int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
    uint160 secondsPerLiquidityCumulativesDelta =
      secondsPerLiquidityCumulativeX128s[1] - secondsPerLiquidityCumulativeX128s[0];

    arithmeticMeanTick = int24(tickCumulativesDelta / int32(secondsAgo));
    // Always round to negative infinity
    if (tickCumulativesDelta < 0 && (tickCumulativesDelta % int32(secondsAgo) != 0)) arithmeticMeanTick--;

    // We are multiplying here instead of shifting to ensure that harmonicMeanLiquidity doesn't overflow uint128
    uint192 secondsAgoX160 = uint192(secondsAgo) * type(uint160).max;
    harmonicMeanLiquidity = uint128(secondsAgoX160 / (uint192(secondsPerLiquidityCumulativesDelta) << 32));
  }

  function getQuoteAtTick(
    int24 tick,
    uint128 baseAmount,
    address baseToken,
    address quoteToken
  ) internal pure returns (uint256 quoteAmount) {
    uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);

    // Calculate quoteAmount with better precision if it doesn't overflow when multiplied by itself
    if (sqrtRatioX96 <= type(uint128).max) {
      uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
      quoteAmount = baseToken < quoteToken
        ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192)
        : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
    } else {
      uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
      quoteAmount = baseToken < quoteToken
        ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128)
        : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
    }
  }
}
