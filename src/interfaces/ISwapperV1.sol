// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/**
 * @title Swapper Contract
 * @author thelostone-mc
 * @notice Simple swapper contract to pool, swap and withdraw tokens
 */
interface ISwapperV1 {
  /*///////////////////////////////////////////////////////////////
                            Structs
  //////////////////////////////////////////////////////////////*/

  /// @notice Struct of user
  struct SwapInfo {
    /// @notice Amount of tokens deposited
    uint256 depositTokenAmount;
    /// @notice Has the user withdrawn their tokens
    bool hasWithdrawn;
  }

  /*///////////////////////////////////////////////////////////////
                            Events
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Emitted when a user deposits tokens
   * @param user The address of the user depositing tokens
   * @param amount The amount of tokens deposited
   */
  event TokensDeposited(address indexed user, uint256 amount);

  /**
   * @notice Emitted when tokens are swapped
   */
  event TokensSwapped();

  /**
   * @notice Emitted when a user withdraws their tokens
   * @param user The address of the user withdrawing tokens
   * @param amount The amount of tokens withdrawn
   */
  event SwappedTokensWithdrawn(address indexed user, uint256 amount);

  /**
   * @notice Emitted when a user withdraws their deposit
   * @param user The address of the user withdrawing their deposit
   * @param amount The amount of tokens withdrawn
   */
  event DepositWithdrawn(address indexed user, uint256 amount);

  /*///////////////////////////////////////////////////////////////
                            Errors
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Thrown if caller has no tokens to withdraw
   */
  error SwapperV1_NoTokensToWithdraw();

  /**
   * @notice Thrown if amount of tokens deposited is not correct
   */
  error SwapperV1_AmountMismatch();

  /**
   * @notice Thrown if swap has already been executed
   */
  error SwapperV1_SwapAlreadyExecuted();

  /**
   * @notice Thrown if user has already withdrawn their tokens
   */
  error SwapperV1_AlreadyWithdrawn();

  /**
   * @notice Thrown if there is not enough liquidity
   */
  error SwapperV1_NotEnoughLiquidity();

  /*///////////////////////////////////////////////////////////////
                            VARIABLES
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice The address of the token deposited for swapping
   */
  function DEPOSITED_TOKEN() external view returns (address);

  /**
   * @notice The address of the token swapped to
   */
  function SWAPPED_TOKEN() external view returns (address);

  /**
   * @notice Whether the swap has been executed
   */
  function swapped() external view returns (bool);

  /**
   * @notice The mapping of user to swap info
   */
  function userToSwapInfo(address _user) external view returns (SwapInfo calldata);

  /*///////////////////////////////////////////////////////////////
                            Logic
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Allows users to de tokens for swapping
   * @param _amount The amount of fromToken to deposit
   */
  function deposit(uint256 _amount) external payable;

  /**
   * @notice Executes the swap of all de tokens
   */
  function swap() external payable;

  /**
   * @notice Allows users to withdraw their swapped tokens
   */
  function withdraw() external;

  /**
   * @notice Allows users to withdraw their deposit
   */
  function withdrawDeposit() external;

  /**
   * @notice Get the amount of tokens a user is entitled to
   * @param _user The address of the user
   * @return The amount of tokens the user is entitled to
   */
  function getSwapTokenAmount(address _user) external view returns (uint256);

  /**
   * @notice Recieve function to allow for ETH transfers
   */
  function recieve() external payable;
}
