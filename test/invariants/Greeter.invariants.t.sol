// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Greeter, IERC20} from '../../src/contracts/Greeter.sol';

interface IHevm {
  function prank(address) external;
}

contract GreeterInvariant {
  address constant HEVM_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;
  IHevm hevm = IHevm(HEVM_ADDRESS);
  Greeter public targetContract;

  constructor() {
    targetContract = new Greeter('a', IERC20(address(1)));
  }

  function checkGreeterNeverEmpty(string memory newGreeting) public {
    (bool success,) = address(targetContract).call(abi.encodeCall(Greeter.setGreeting, newGreeting));

    assert((success && keccak256(bytes(targetContract.greeting())) != keccak256(bytes(''))) || !success);
  }

  function checkOnlyOwnerSetsGreeting(address caller) public {
    hevm.prank(caller);

    (bool success,) = address(this).call(abi.encodeCall(Greeter.setGreeting, 'hello'));

    assert((success && msg.sender == targetContract.OWNER()) || (!success && msg.sender != targetContract.OWNER()));
  }
}
