pragma solidity ^0.8.19;

import {IWrapper} from '../../../../interfaces/Oracle/IWrapper.sol';
import {FeedRegistryInterface} from '@chainlink/contracts/src/v0.8/interfaces/FeedRegistryInterface.sol';

contract ChainlinkWrapper is IWrapper {
  FeedRegistryInterface constant _registry = FeedRegistryInterface(0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf);
  address constant dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address constant usdt = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
  address constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address constant wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

  constructor() {}

  function getAmountOut(
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut
  ) public view returns (uint256 _amountOut) {
    if (_tokenIn == dai || _tokenIn == usdt || _tokenIn == usdc) {
      _tokenIn = address(840);
    } else if (_tokenIn == weth) {
      _tokenIn = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    } else if (_tokenIn == wbtc) {
      _tokenIn = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;
    }

    if (_tokenOut == dai || _tokenOut == usdt || _tokenOut == usdc) {
      _tokenOut = address(840);
    } else if (_tokenOut == weth) {
      _tokenOut = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    } else if (_tokenOut == wbtc) {
      _tokenOut = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;
    }

    (, int256 _price,,,) = _registry.latestRoundData(_tokenIn, _tokenOut);
    _amountOut = _amountIn * uint256(_price) / 10 ** _registry.decimals(_tokenIn, _tokenOut);
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
