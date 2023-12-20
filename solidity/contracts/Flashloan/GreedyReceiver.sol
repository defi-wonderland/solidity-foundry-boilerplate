pragma solidity ^0.8.19;

import {IFlashloan} from '../../interfaces/Flashloan/IFlashloan.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

error OnlyPool();

contract GreedyReceiver {
  IFlashloan public pool;

  using SafeERC20 for IERC20;

  modifier onlyPool() {
    if (msg.sender != address(pool)) revert OnlyPool();
    _;
  }

  constructor(address _poolAddress) {
    pool = IFlashloan(_poolAddress);
  }

  function flashLoan(uint256 _amount, address _token) external {
    pool.flashloan(_amount, _token);
  }

  function getETH() external payable onlyPool {}

  function getTokens(address _token, uint256 _amount) external onlyPool {}
}
