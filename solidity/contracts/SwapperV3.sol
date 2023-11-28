pragma solidity ^0.8.19;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {IUniswapV2Router01} from '@uniswap/periphery/interfaces/IUniswapV2Router01.sol';
import {IUniswapV2Pair} from '@uniswap/core/interfaces/IUniswapV2Pair.sol';
import {ISwapperV3} from '../interfaces/ISwapperV3.sol';
import {IKeep3rV2} from '../interfaces/IKeep3rV2.sol';

/// @title Swapper contract V2
/// @author 0xdeo
/// @notice Allows friends to pool their tokens and make a swap
/// @notice Routes swaps thru Uniswap
contract SwapperV3 is ISwapperV3 {
  using SafeERC20 for IERC20;

  IERC20 constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  IERC20 constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

  IUniswapV2Router01 constant router = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
  IUniswapV2Pair constant pair = IUniswapV2Pair(0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11);

  mapping(uint256 => Swap) public swaps;
  uint256 swapId;

  uint256 lastWorked;
  address keep3r = 0xdc02981c9C062d48a9bD54adBf51b816623dcc6E;

  constructor() {}

  modifier validateAndPayKeeper(address _keeper) {
    if (!IKeep3rV2(keep3r).isKeeper(_keeper)) revert KeeperNotValid();
    _;
    IKeep3rV2(keep3r).worked(_keeper);
  }

  /// @notice Can only provide tokens when swap hasn't been done yet
  /// @notice Cannot provide tokens if fromToken balance will exceed contract's toToken balance
  /// @notice User's deposit gets recorded in latest epoch, and the swapId recording his deposit is then returned
  function provide() public payable returns (uint256) {
    swaps[swapId].balances[msg.sender] += msg.value;

    emit Provide(msg.sender, msg.value, swapId);
    return swapId;
  }

  /// @notice Initiates swap by sealing off further deposits and allowing withdrawals of toTokens, for that swapId's epoch
  /// @notice Sends any deposited fromTokens to the owner of the contract who provided initial liquidity
  function swap() public {
    address[] memory _path = new address[](2);
    _path[0] = address(WETH);
    _path[1] = address(DAI);
    (uint256 _reserve0, uint256 _reserve1,) = pair.getReserves();
    uint256 _amountOutMin;
    uint256 _amountOut = DAI.balanceOf(address(this));
    uint256 _amountIn = address(this).balance;

    swaps[swapId].swapped = true;
    swapId++;

    if (address(WETH) == pair.token0()) {
      _amountOutMin = router.getAmountOut(address(this).balance, _reserve0, _reserve1);
    } else {
      _amountOutMin = router.getAmountOut(address(this).balance, _reserve1, _reserve0);
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
      payable(msg.sender).transfer(balance);
    }

    emit Withdraw(msg.sender, balance, _swapId, _refunded);
  }

  function work() external validateAndPayKeeper(msg.sender) {
    if (!workable()) {
      revert JobNotReady();
    }

    lastWorked = block.timestamp;

    swap();
  }

  function workable() public view returns (bool) {
    if (block.timestamp >= lastWorked + 600) {
      return true;
    }

    return false;
  }
}
