// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from 'forge-std/interfaces/IERC20.sol';

/**
 * @title Greeter Contract
 * @author Wonderland
 * @notice This is a basic contract created in order to portray some
 * best practices and foundry functionality.
 */
interface IGreeter {
  /*///////////////////////////////////////////////////////////////
                            EVENTS
  //////////////////////////////////////////////////////////////*/
  /**
   * @notice Greeting has changed
   * @param _greeting The new greeting
   */
  event GreetingSet(string _greeting);

  /**
   * @notice Greet has been called
   * @param _greeting The greeting
   * @param _balance Current token balance of the caller
   */
  event Greeting(string _greeting, uint256 _balance);

  /*///////////////////////////////////////////////////////////////
                            ERRORS
  //////////////////////////////////////////////////////////////*/
  /**
   * @notice Throws if the function was called by someone else than the owner
   */
  error Greeter_OnlyOwner();

  /**
   * @notice Throws if the greeting set is invalid
   * @dev Empty string is an invalid greeting
   */
  error Greeter_InvalidGreeting();

  /*///////////////////////////////////////////////////////////////
                            VARIABLES
  //////////////////////////////////////////////////////////////*/
  /**
   * @notice Returns the owner of the contract
   * @dev The owner will always be the deployer of the contract
   * @return _owner The owner of the contract
   */
  function OWNER() external view returns (address _owner);

  /**
   * @notice Returns the token used to greet callers
   * @return _token The address of the token
   */
  function TOKEN() external view returns (IERC20 _token);

  /**
   * @notice Returns the previously set greeting
   * @return _greet The greeting
   */
  function greeting() external view returns (string memory _greet);

  /*///////////////////////////////////////////////////////////////
                            LOGIC
  //////////////////////////////////////////////////////////////*/
  /**
   * @notice Sets a new greeting
   * @dev Only callable by the owner
   * @param _newGreeting The new greeting to be set
   */
  function setGreeting(string memory _newGreeting) external;

  /**
   * @notice Greets the caller
   * @return _greeting The greeting
   * @return _balance Current token balance of the caller
   */
  function greet() external returns (string memory _greeting, uint256 _balance);
}
