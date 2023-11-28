pragma solidity ^0.8.19;

/// @title Swapper interface
/// @author 0xdeo
/// @notice Defines custom errors, function signatures and a struct for the swapper contract
interface ISwapper {
  function provide(uint256 _amount) external returns (uint256);
  function swap() external;
  function withdraw(uint256 _swapId) external;
  function provideLiquidity(uint256 _liquidity) external;

  error InsufficientLiquidity();
  error ZeroBalance();

  event Provide(address _depositor, uint256 _amount, uint256 _swapId);
  event Swapped(uint256 _swapId);
  event Withdraw(address _depositor, uint256 _amount, uint256 _swapId, bool _refunded);
  event LiquidityAdded(uint256 _liquidity);

  struct Swap {
    bool swapped;
    mapping(address => uint256) balances;
  }
}
