// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Greeter, IERC20} from 'contracts/Greeter.sol';
import {CommonBase} from 'forge-std/Base.sol';

contract InvariantGreeter is CommonBase {
  Greeter internal _targetContract;

  constructor() {
    _targetContract = new Greeter('a', IERC20(address(1)));
  }

  /// @custom:property-id 2
  /// @custom:property Only the owner can set the greeting
  function handler_unguided_setGreeting(address _caller, string memory _newGreeting) external {
    vm.prank(_caller);
    try _targetContract.setGreeting(_newGreeting) {
      assert(keccak256(bytes(_targetContract.greeting())) == keccak256(bytes(_newGreeting)));
      assert(_caller == _targetContract.OWNER());
    } catch {
      assert(_caller != _targetContract.OWNER() || keccak256(bytes(_newGreeting)) == keccak256(''));
    }
  }

  function handler_guided_setGreeting(string memory _newGreeting) external {
    // no need to prank since this contract deployed the greeter and is therefore its owner
    try _targetContract.setGreeting(_newGreeting) {
      assert(keccak256(bytes(_targetContract.greeting())) == keccak256(bytes(_newGreeting)));
    } catch {
      assert(keccak256(bytes(_newGreeting)) == keccak256(''));
    }
  }

  /// @custom:property-id 1
  /// @custom:property Greeting should never be empty
  function property_greetingIsNeverEmpty() external view {
    assert(keccak256(bytes(_targetContract.greeting())) != keccak256(''));
  }
}
