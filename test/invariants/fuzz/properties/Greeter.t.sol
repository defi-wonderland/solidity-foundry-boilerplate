// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {GreeterSetup} from '../setup/Greeter.t.sol';

contract GreeterProperties is GreeterSetup {
  /// @custom:property-id 1
  /// @custom:property Greeting should never be empty
  function property_greetingIsNeverEmpty() external view {
    assert(keccak256(bytes(_targetContract.greeting())) != keccak256(''));
  }
}
