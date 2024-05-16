// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Greeter, IERC20} from '../../src/contracts/Greeter.sol';

contract GreeterInvariant is Greeter {
  constructor() Greeter('a', IERC20(address(1))) {}

  function echidna_greeterNeverEmpty() public view returns (bool) {
    return keccak256(bytes(greeting)) != keccak256('');
  }

  function echidna_onlyOwnerSetsGreeting() public returns (bool) {
    // new greeting set, is the sender the owner?
    try this.setGreeting('hello') {
      if (msg.sender != OWNER) return false;
      return true;
    } catch {
      // new greeting failed, is the sender not the owner?
      if (msg.sender == OWNER) return false;
      return true;
    }
  }
}
