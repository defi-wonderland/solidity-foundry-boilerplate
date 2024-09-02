// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Greeter, IERC20} from 'contracts/Greeter.sol';

import {Test} from 'forge-std/Test.sol';
import {SymTest} from 'halmos-cheatcodes/src/SymTest.sol'; // See https://github.com/a16z/halmos-cheatcodes?tab=readme-ov-file

contract SymbolicGreeter is SymTest, Test {
  Greeter public targetContract;

  function setUp() public {
    string memory _initialGreeting = svm.createString(64, 'initial greeting');
    address _token = svm.createAddress('token');

    targetContract = new Greeter(_initialGreeting, IERC20(_token));
  }

  function check_validState_greeterNeverEmpty(
    address _caller
  ) public {
    // Input conditions: any caller
    vm.prank(_caller);

    // Execution: Halmos cannot use a dynamic-sized array, iterate over multiple string lengths
    bool _success;
    for (uint256 i = 1; i < 3; i++) {
      string memory greeting = svm.createString(i, 'greeting');
      (_success,) = address(targetContract).call(abi.encodeCall(Greeter.setGreeting, (greeting)));

      // Output condition check
      vm.assume(_success); // discard failing calls
      assert(keccak256(bytes(targetContract.greeting())) != keccak256(bytes('')));
    }

    // Add the empty string (bypass the non-empty check of svm.createString)
    (_success,) = address(targetContract).call(abi.encodeCall(Greeter.setGreeting, ('')));

    // Output condition check
    vm.assume(_success); // discard failing calls
    assert(keccak256(bytes(targetContract.greeting())) != keccak256(bytes('')));
  }

  function check_setGreeting_onlyOwnerSetsGreeting(
    address _caller
  ) public {
    // Input conditions
    string memory _newGreeting = svm.createString(64, 'new greeting');

    // Execution
    vm.prank(_caller);
    (bool _success,) = address(targetContract).call(abi.encodeCall(Greeter.setGreeting, (_newGreeting)));

    // Output condition check
    if (_success) {
      assert(_caller == targetContract.OWNER());
      assert(keccak256(bytes(targetContract.greeting())) == keccak256(bytes(_newGreeting)));
    } else {
      assert(_caller != targetContract.OWNER() || keccak256(bytes(_newGreeting)) == keccak256(bytes('')));
    }
  }
}
