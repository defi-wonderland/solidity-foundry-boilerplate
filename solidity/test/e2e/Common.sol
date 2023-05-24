// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {DSTestFull} from 'test/utils/DSTestFull.sol';
import {console} from 'forge-std/console.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

import {Greeter, IGreeter} from 'contracts/Greeter.sol';

contract CommonE2EBase is DSTestFull {
  uint256 internal constant _FORK_BLOCK = 8_945_216;

  string internal _initialGreeting = 'hola';
  address internal _user = _label('user');
  address internal _owner = _label('owner');
  address internal _daiWhale = 0x93e39f67f79B448ABd58fC7Ef813c55636c4510f;
  IERC20 internal _dai = IERC20(0x65a5ba240CBd7fD75700836b683ba95EBb2F32bd);
  IGreeter internal _greeter;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('goerli'), _FORK_BLOCK);
    vm.prank(_owner);
    _greeter = new Greeter(_initialGreeting, _dai);
  }
}
