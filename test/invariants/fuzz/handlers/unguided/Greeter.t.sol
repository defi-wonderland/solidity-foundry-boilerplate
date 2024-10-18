// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {GreeterSetup} from '../../setup/Greeter.t.sol';

contract GreeterUnguidedHandlers is GreeterSetup {
  /// @custom:property-id 2
  /// @custom:property Only the owner can set the greeting
  function handler_setGreeting(address _caller, string memory _newGreeting) external {
    vm.prank(_caller);
    try _targetContract.setGreeting(_newGreeting) {
      assert(keccak256(bytes(_targetContract.greeting())) == keccak256(bytes(_newGreeting)));
      assert(_caller == _targetContract.OWNER());
    } catch {
      assert(_caller != _targetContract.OWNER() || keccak256(bytes(_newGreeting)) == keccak256(''));
    }
  }
}
