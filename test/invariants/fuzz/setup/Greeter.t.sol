// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Greeter, IERC20} from 'contracts/Greeter.sol';
import {CommonBase} from 'forge-std/Base.sol';

contract GreeterSetup is CommonBase {
  Greeter internal _targetContract;

  constructor() {
    _targetContract = new Greeter('a', IERC20(address(1)));
  }
}
