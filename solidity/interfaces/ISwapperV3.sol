pragma solidity ^0.8.19;

/// @title Swapper interface
/// @author 0xdeo
/// @notice Defines custom errors, function signatures and a struct for the swapper contract
interface ISwapperV3 {
  function provide() external payable returns (uint256);
  function swap() external;
  function withdraw(uint256 _swapId) external;

  error ZeroBalance();
  error KeeperNotValid();
  error JobNotReady();

  event Provide(address _depositor, uint256 _amount, uint256 _swapId);
  event Swapped(uint256 _swapId);
  event Withdraw(address _depositor, uint256 _amount, uint256 _swapId, bool _refunded);
  event LiquidityAdded(uint256 _liquidity);

  struct Swap {
    bool swapped;
    uint256 totalIn;
    uint256 totalOut;
    mapping(address => uint256) balances;
  }
}
