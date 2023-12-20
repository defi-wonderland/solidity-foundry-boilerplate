pragma solidity ^0.8.19;

import {I1inch} from './Interfaces/I1inch.sol';
import {IWrapper} from '../../../../interfaces/Oracle/IWrapper.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract OneInchWrapper is IWrapper {
  address constant _1inch = 0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E;

  constructor() {}

  function getAmountOut(
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut
  ) public view returns (uint256 _amountOut) {
    (_amountOut,) = I1inch(_1inch).getExpectedReturn(IERC20(_tokenIn), IERC20(_tokenOut), _amountIn, 1, 0);
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
