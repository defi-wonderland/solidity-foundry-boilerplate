// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import {CommonE2EBase} from 'test/e2e/Common.sol';

contract E2EGreeter is CommonE2EBase {
  function test_Greet() public {
    uint256 _whaleBalance = _dai.balanceOf(_daiWhale);

    vm.prank(_daiWhale);
    (string memory _greeting, uint256 _balance) = _greeter.greet();

    assertEq(_whaleBalance, _balance);
    assertEq(_initialGreeting, _greeting);
  }
}
