pragma solidity ^0.8.19;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {IUniswapV2Router01} from '@uniswap/periphery/interfaces/IUniswapV2Router01.sol';
import {IUniswapV2Pair} from '@uniswap/core/interfaces/IUniswapV2Pair.sol';
import {ISwapperV3} from '../../interfaces/Swapper/ISwapperV3.sol';
import {Keeper} from './Keeper.sol';

/// @title Swapper contract V2
/// @author 0xdeo
/// @notice Allows friends to pool their tokens and make a swap
/// @notice Routes swaps thru Uniswap
contract SwapperV3 is ISwapperV3, Keeper {
  using SafeERC20 for IERC20;

  IERC20 constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

  IUniswapV2Router01 constant router = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
  IUniswapV2Pair constant pair = IUniswapV2Pair(0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11);

  mapping(uint256 _swapId => Swap _swapData) public swaps;
  uint256 swapId;

  constructor() {}

  /// @notice Can provide ETH when swap hasn't been done yet
  /// @notice Cannot provide tokens if fromToken balance will exceed contract's toToken balance
  /// @notice User's deposit gets recorded in latest epoch, and the swapId recording his deposit is then returned
  function provide() public payable returns (uint256 _swapId) {
    swaps[swapId].balances[msg.sender] += msg.value;

    emit Provide(msg.sender, msg.value, swapId);
    return swapId;
  }

  /// @notice Can provide WETH when swap hasn't been done yet
  /// @notice Cannot provide tokens if fromToken balance will exceed contract's toToken balance
  /// @notice User's deposit gets recorded in latest epoch, and the swapId recording his deposit is then returned
  /// @param  _deposit amount of WETH the user deposited
  function provide(uint256 _deposit) public payable returns (uint256 _swapId) {
    swaps[swapId].balances[msg.sender] += _deposit;

    WETH.transferFrom(msg.sender, address(this), _deposit);

    emit Provide(msg.sender, msg.value, swapId);
    return swapId;
  }

  /// @notice Initiates swap by sealing off further deposits and allowing withdrawals of toTokens, for that swapId's epoch
  /// @notice Sends any deposited fromTokens to the owner of the contract who provided initial liquidity
  function swap() public virtual override(ISwapperV3, Keeper) {
    address[] memory _path = new address[](2);
    _path[0] = address(WETH);
    _path[1] = address(DAI);
    (uint256 _reserve0, uint256 _reserve1,) = pair.getReserves();
    uint256 _amountOutMin;
    uint256 _amountOut;
    uint256 _amountIn = address(this).balance;

    swaps[swapId].swapped = true;
    ++swapId;

    if (address(WETH) == pair.token0()) {
      _amountOutMin = router.getAmountOut(address(this).balance, _reserve0, _reserve1);
    } else {
      _amountOutMin = router.getAmountOut(address(this).balance, _reserve1, _reserve0);
    }

    if (WETH.balanceOf(address(this)) != 0) {
      WETH.withdraw(WETH.balanceOf(address(this)));
    }

    // 1% slippage to prevent frontrunning
    _amountOut = router.swapExactETHForTokens{value: address(this).balance}(
      _amountOutMin * 99 / 100, _path, address(this), block.timestamp
    )[1];

    //_amountOut = DAI.balanceOf(address(this)) - _amountOut;
    swaps[swapId - 1].totalOut = _amountOut;
    swaps[swapId - 1].totalIn = _amountIn;

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
      balance = (balance * swaps[_swapId].totalOut) / swaps[_swapId].totalIn;
      DAI.safeTransfer(msg.sender, balance);
    } else {
      _refunded = true;

      (bool _success,) = payable(msg.sender).call{value: balance}('');

      if (!_success) {
        revert RefundFailed();
      }
    }

    emit Withdraw(msg.sender, balance, _swapId, _refunded);
  }

  receive() external payable {
    provide();
  }
}
