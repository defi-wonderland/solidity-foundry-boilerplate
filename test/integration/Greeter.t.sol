// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IntegrationBase} from 'test/integration/IntegrationBase.sol';

contract IntegrationGreeter is IntegrationBase {
  function test_Greet() public {
    uint256 _whaleBalance = _dai.balanceOf(_daiWhale);

    vm.prank(_daiWhale);
    (string memory _greeting, uint256 _balance) = _greeter.greet();

    assertEq(_whaleBalance, _balance);
    assertEq(_initialGreeting, _greeting);
  }
}
