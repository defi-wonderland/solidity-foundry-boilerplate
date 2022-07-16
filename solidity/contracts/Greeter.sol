// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <0.9.0;

import '../interfaces/IGreeter.sol';

contract Greeter is IGreeter {
    // Greeting 
    string private greeting;
    // Empty string for revert checks
    bytes32 private constant _EMPTY = keccak256(bytes(''));

    /// @inheritdoc IGreeter
    address public immutable OWNER;

    /**
     * @notice Defines the owner to the msg.sender and sets the 
               initial greeting
     *
     * @param _greeting Initial greeting
     */
    constructor(string memory _greeting) {
        OWNER = msg.sender;
        setGreeting(_greeting);
    }

    /// @inheritdoc IGreeter
    function greet() external view returns (string memory) {
        return string.concat('Greeting sir, ', greeting);
    }

    /// @inheritdoc IGreeter
    function setGreeting(string memory _greeting) public onlyOwner {
        if (keccak256(bytes(_greeting)) == _EMPTY) revert Greeter_OnlyOwner();

        greeting = _greeting;
        emit GreetingSet(_greeting);
    }

    /**
     * @notice Reverts in case the function was not called by
               the owner of the contract
     */
    modifier onlyOwner() {
      if (msg.sender != OWNER) revert Greeter_OnlyOwner();
      _;
    }
}
