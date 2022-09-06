// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import {CommonE2EBase} from 'test/e2e/Common.sol';

contract E2EGreeter is CommonE2EBase {
    function test_Greet() public {
        uint256 whaleBalance = dai.balanceOf(daiWhale);

        vm.prank(daiWhale);
        (string memory greeting, uint256 balance) = greeter.greet();

        assertEq(whaleBalance, balance);
        assertEq(initialGreeting, greeting);
    }
}
