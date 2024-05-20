// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Greeter, IERC20} from 'contracts/Greeter.sol';

interface IHevm {
  function prank(address) external;
}

contract InvariantGreeter {
  address constant HEVM_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;
  IHevm hevm = IHevm(HEVM_ADDRESS);
  Greeter public targetContract;

  constructor() {
    targetContract = new Greeter('a', IERC20(address(1)));
  }

  function checkGreeterNeverEmpty(string memory newGreeting) public {
    // Execution
    (bool success,) = address(targetContract).call(abi.encodeCall(Greeter.setGreeting, newGreeting));

    // Check output condition
    assert((success && keccak256(bytes(targetContract.greeting())) != keccak256(bytes(''))) || !success);
  }

  function checkOnlyOwnerSetsGreeting(address caller) public {
    // Input conditions
    hevm.prank(caller);

    // Execution
    (bool success,) = address(this).call(abi.encodeCall(Greeter.setGreeting, 'hello'));

    // Check output condition
    assert((success && msg.sender == targetContract.OWNER()) || (!success && msg.sender != targetContract.OWNER()));
  }
}
