pragma solidity ^0.8.19;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {IReceiver} from '../../interfaces/Flashloan/IReceiver.sol';
import {IFlashloan} from '../../interfaces/Flashloan/IFlashloan.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

// Without reentrancy guard, user can make a flashloan attack by using his flashloan to deposit into the pool
contract Flashloan is IFlashloan, ReentrancyGuard {
  using SafeERC20 for IERC20;

  mapping(address _user => mapping(address _token => uint256 _amount)) tokenBalances;
  mapping(address _user => uint256 _amount) ethBalances;

  constructor() {}

  /// @dev allows users to flashloan any tokens or eth deposited in the pool
  /// @dev If address(0) is passed as _token, this is treated as ETH
  /// @param _amount flashloan total desired, must not exceed pool balance
  /// @param _token token (or eth) to be flashloaned
  function flashloan(uint256 _amount, address _token) external nonReentrant {
    if (address(_token) == address(0)) {
      uint256 poolBalance = address(this).balance;
      if (_amount > poolBalance) revert InsufficientPoolBalance();

      IReceiver(msg.sender).getETH{value: _amount}();

      uint256 balanceAfter = address(this).balance;

      if (balanceAfter < poolBalance + (poolBalance * 1e13) / 1e18) revert InsufficientRepayment();
    } else {
      uint256 poolBalance = IERC20(_token).balanceOf(address(this));
      if (_amount > poolBalance) revert InsufficientPoolBalance();

      IERC20(_token).safeTransfer(msg.sender, _amount);
      IReceiver(msg.sender).getTokens(_token, _amount);

      uint256 balanceAfter = IERC20(_token).balanceOf(address(this));

      if (balanceAfter < poolBalance + (poolBalance * 1e13) / 1e18) revert InsufficientRepayment();
    }
  }

  /// @dev Deposit function for erc20 tokens or eth
  /// @dev if _token address is address(0), this is an eth deposit
  /// @param _amount Amount of token to deposit
  /// @param _token Address of token to deposit
  function deposit(uint256 _amount, address _token) external payable nonReentrant {
    if (_token == address(0)) {
      ethBalances[msg.sender] += msg.value;
    } else {
      IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
      tokenBalances[msg.sender][_token] += _amount;
    }
  }

  /// @dev Withdraw function for erc20 tokens or eth
  /// @dev if _token address is address(0), this is an eth withdrawal
  /// @param _amount Amount of token to withdraw
  /// @param _token Address of token to withdraw
  function withdraw(uint256 _amount, address _token) external nonReentrant {
    if (_token == address(0)) {
      ethBalances[msg.sender] -= _amount;
      (bool success,) = payable(msg.sender).call{value: _amount}('');
      require(success, 'Failed to send ETH');
    } else {
      tokenBalances[msg.sender][_token] -= _amount;
      IERC20(_token).safeTransfer(msg.sender, _amount);
    }
  }

  /// @dev users can deposit eth by sending it directly to the contract
  receive() external payable {}
}
