// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Greeter, IERC20} from 'contracts/Greeter.sol';

import {Test} from 'forge-std/Test.sol';
import {SymTest} from 'halmos-cheatcodes/src/SymTest.sol';

contract GreeterSymbolic is SymTest, Test {
  Greeter public targetContract;

  function setUp() public {
    string memory initialGreeting = svm.createString(64, 'initial greeting');
    address token = svm.createAddress('token');

    targetContract = new Greeter(initialGreeting, IERC20(token));
  }

  function check_validState_greeterNeverEmpty(address caller) public {
    // Input conditions: any caller
    vm.prank(caller);

    // Execution: Halmos cannot use a dynamic-sized array, iterate over multiple string lengths
    bool success;
    for (uint256 i = 1; i < 3; i++) {
      string memory greeting = svm.createString(i, 'greeting');
      (success,) = address(targetContract).call(abi.encodeCall(Greeter.setGreeting, (greeting)));

      // Output condition check
      vm.assume(success); // discard failing calls
      assert(keccak256(bytes(targetContract.greeting())) != keccak256(bytes('')));
    }

    // Add the empty string (bypass the non-empty check of svm.createString)
    (success,) = address(targetContract).call(abi.encodeCall(Greeter.setGreeting, ('')));

    // Output condition check
    vm.assume(success); // discard failing calls
    assert(keccak256(bytes(targetContract.greeting())) != keccak256(bytes('')));
  }

  function check_setGreeting_onlyOwnerSetsGreeting(address caller) public {
    // Input conditions
    string memory newGreeting = svm.createString(64, 'new greeting');

    // Execution
    vm.prank(caller);
    (bool success,) = address(targetContract).call(abi.encodeCall(Greeter.setGreeting, (newGreeting)));

    // Output condition check
    if (success) {
      assert(caller == targetContract.OWNER());
      assert(keccak256(bytes(targetContract.greeting())) == keccak256(bytes(newGreeting)));
    } else {
      assert(caller != targetContract.OWNER() || keccak256(bytes(newGreeting)) == keccak256(bytes('')));
    }
  }
}
