pragma solidity ^0.8.19;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {ISwapper} from '../interfaces/ISwapper.sol';

/// @title Swapper contract
/// @author 0xdeo
/// @notice Allows friends to pool their tokens and make a swap
/// @notice Requires a trusted third party to provide initial liquidity
contract Swapper is ISwapper, Ownable {
  using SafeERC20 for IERC20;

  IERC20 fromToken;
  IERC20 toToken;

  uint256 netLiquidity;

  mapping(uint256 => Swap) public swaps;
  uint256 swapId;

  constructor(address _fromToken, address _toToken) Ownable(msg.sender) {
    fromToken = IERC20(_fromToken);
    toToken = IERC20(_toToken);
  }

  /// @notice Can only provide tokens when swap hasn't been done yet
  /// @notice Cannot provide tokens if fromToken balance will exceed contract's toToken balance
  /// @notice User's deposit gets recorded in latest epoch, and the swapId recording his deposit is then returned
  /// @param _amount Amount of fromTokens to provide
  function provide(uint256 _amount) public returns (uint256) {
    if (netLiquidity < _amount) {
      revert InsufficientLiquidity();
    }

    swaps[swapId].balances[msg.sender] += _amount;
    netLiquidity -= _amount;

    fromToken.safeTransferFrom(msg.sender, address(this), _amount);

    emit Provide(msg.sender, _amount, swapId);
    return swapId;
  }

  /// @notice Initiates swap by sealing off further deposits and allowing withdrawals of toTokens, for that swapId's epoch
  /// @notice Sends any deposited fromTokens to the owner of the contract who provided initial liquidity
  function swap() public onlyOwner {
    swaps[swapId].swapped = true;
    swapId++;

    fromToken.safeTransfer(owner(), fromToken.balanceOf(address(this)));

    emit Swapped(swapId - 1);
  }

  /// @notice User must have nonzero balance
  /// @notice If swap has been initiated, he receives toTokens in 1:1 ratio to his deposit
  /// @notice Otherwise he is refunded the full amount he deposited.
  /// @param _swapId ID designating epoch user's deposit belonged to
  function withdraw(uint256 _swapId) public {
    uint256 balance = swaps[_swapId].balances[msg.sender];
    swaps[_swapId].balances[msg.sender] = 0;

    if (balance == 0) {
      revert ZeroBalance();
    }

    bool _refunded;
    if (swaps[_swapId].swapped) {
      toToken.safeTransfer(msg.sender, balance);
    } else {
      netLiquidity += balance;
      _refunded = true;
      fromToken.safeTransfer(msg.sender, balance);
    }

    emit Withdraw(msg.sender, balance, _swapId, _refunded);
  }

  /// @notice Can only provide tokens when swap hasn't been done yet
  /// @param _liquidity amount of toTokens to provide as liquidity
  function provideLiquidity(uint256 _liquidity) public onlyOwner {
    netLiquidity += _liquidity;
    toToken.safeTransferFrom(msg.sender, address(this), _liquidity);

    emit LiquidityAdded(_liquidity);
  }
}
