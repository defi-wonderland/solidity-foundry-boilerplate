// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Greeter, IERC20} from 'contracts/Greeter.sol';

interface IHevm {
  function prank(address) external;
}

contract InvariantGreeter {
  // See https://github.com/a16z/halmos-cheatcodes?tab=readme-ov-file
  IHevm internal _hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

  Greeter internal _targetContract;

  constructor() {
    _targetContract = new Greeter('a', IERC20(address(1)));
  }

  function checkGreeterNeverEmpty(string memory newGreeting) public {
    // Execution
    (bool success,) = address(_targetContract).call(abi.encodeCall(Greeter.setGreeting, newGreeting));

    // Check output condition
    assert((success && keccak256(bytes(_targetContract.greeting())) != keccak256(bytes(''))) || !success);
  }

  function checkOnlyOwnerSetsGreeting(address caller) public {
    // Input conditions
    _hevm.prank(caller);

    // Execution
    (bool success,) = address(this).call(abi.encodeCall(Greeter.setGreeting, 'hello'));

    // Check output condition
    assert((success && msg.sender == _targetContract.OWNER()) || (!success && msg.sender != _targetContract.OWNER()));
  }
}
