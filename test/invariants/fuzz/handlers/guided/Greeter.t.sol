// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {GreeterSetup} from '../../setup/Greeter.t.sol';

contract GreeterGuidedHandlers is GreeterSetup {
  function handler_setGreeting(string memory _newGreeting) external {
    // no need to prank since this contract deployed the greeter and is therefore its owner
    try _targetContract.setGreeting(_newGreeting) {
      assert(keccak256(bytes(_targetContract.greeting())) == keccak256(bytes(_newGreeting)));
    } catch {
      assert(keccak256(bytes(_newGreeting)) == keccak256(''));
    }
  }
}
