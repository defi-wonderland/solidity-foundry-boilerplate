// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Greeter, IERC20} from 'contracts/Greeter.sol';

interface IHevm {
  function prank(
    address
  ) external;
}

contract InvariantGreeter {
  IHevm internal _hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

  Greeter internal _targetContract;

  constructor() {
    _targetContract = new Greeter('a', IERC20(address(1)));
  }

  function checkGreeterNeverEmpty(
    string memory _newGreeting
  ) public {
    // Execution
    (bool _success,) = address(_targetContract).call(abi.encodeCall(Greeter.setGreeting, _newGreeting));

    // Check output condition
    assert((_success && keccak256(bytes(_targetContract.greeting())) != keccak256(bytes(''))) || !_success);
  }

  function checkOnlyOwnerSetsGreeting(
    address _caller
  ) public {
    // Input conditions
    _hevm.prank(_caller);

    // Execution
    (bool _success,) = address(this).call(abi.encodeCall(Greeter.setGreeting, 'hello'));

    // Check output condition
    assert((_success && msg.sender == _targetContract.OWNER()) || (!_success && msg.sender != _targetContract.OWNER()));
  }
}
