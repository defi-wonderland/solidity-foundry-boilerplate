// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import 'isolmate/interfaces/tokens/IERC20.sol';

/**
 * @title Greeter Contract
 * @author Wonderland
 * @notice This is a basic contract created in order to portray some
 * best practices and foundry functionality.
 */
interface IGreeter {
    ///////////////////////////////////////////////////////// EVENTS
    /**
     * @notice Greeting has changed
     * @param _greeting The new greeting
     */
    event GreetingSet(string _greeting);

    ///////////////////////////////////////////////////////// ERRORS
    /**
     * @notice Throws if the function was called by someone else than the owner
     */
    error Greeter_OnlyOwner();

    /**
     * @notice Throws if the greeting set is invalid
     * @dev Empty string is an invalid greeting
     */
    error Greeter_InvalidGreeting();

    ////////////////////////////////////////////////////// VARIABLES
    /**
     * @notice Returns the owner of the contract
     * @dev The owner will always be the deployer of the contract
     * @return The owner of the contract
     */
    function OWNER() external view returns (address);

    /**
     * @notice Returns the greeting
     * @return The greeting
     */
    function greeting() external view returns (string memory);

    /**
     * @notice Returns the token used to greet callers
     * @return The address of the token
     */
    function token() external view returns (IERC20);

    /**
     * @notice Returns set previously set greeting
     *
     * @return _greeting The greeting
     * @return _balance  Current token balance of the caller
     */
    function greet() external view returns (string memory _greeting, uint256 _balance);

    ////////////////////////////////////////////////////////// LOGIC
    /**
     * @notice Sets a new greeting
     * @dev Only callable by the owner
     * @param _newGreeting The new greeting to be set
     */
    function setGreeting(string memory _newGreeting) external;
}
