// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Greeter, IERC20} from 'contracts/Greeter.sol';

import {Test} from 'forge-std/Test.sol';
import {SymTest} from 'halmos-cheatcodes/src/SymTest.sol';

contract GreeterSymbolic is SymTest, Test {
  Greeter public targetContract;

  function setUp() public {
    string memory _initialGreeting = svm.createString(64, 'initial greeting');
    address _token = svm.createAddress('token');

    targetContract = new Greeter(_initialGreeting, IERC20(_token));
  }

  function check_validState_greeterNeverEmpty(address caller, bytes4 selector) public {
    // Input conditions: any caller
    vm.prank(caller);

    // Execution
    (bool success,) = address(targetContract).call(gen_calldata(selector));

    // Output condition check
    vm.assume(success); // discard failing calls
    assert(keccak256(bytes(targetContract.greeting())) != keccak256(''));
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
      assert(caller != targetContract.OWNER() || keccak256(bytes(newGreeting)) == keccak256(''));
    }
  }

  // either return a valid call to setGreeting or nothing (avoid halmos panicking on unknown contract call)
  function gen_calldata(bytes4 selector) public view returns (bytes memory newCalldata) {
    if (selector == targetContract.setGreeting.selector) {
      string memory greeting = svm.createString(64, 'greeting');
      newCalldata = abi.encodeWithSelector(selector, greeting);
    }
  }
}
