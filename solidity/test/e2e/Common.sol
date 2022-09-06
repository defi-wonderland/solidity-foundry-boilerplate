// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import {DSTestFull} from 'test/utils/DSTestFull.sol';
import {console} from 'forge-std/console.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

import {Greeter, IGreeter} from 'contracts/Greeter.sol';

contract CommonE2EBase is DSTestFull {
    uint256 constant FORK_BLOCK = 15452788;

    string initialGreeting = 'hola';
    address user = label('user');
    address owner = label('owner');
    address daiWhale = 0x42f8CA49E88A8fd8F0bfA2C739e648468b8f9dec;
    IERC20 dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IGreeter greeter;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl('mainnet'), FORK_BLOCK);
        vm.prank(owner);
        greeter = new Greeter(initialGreeting, dai);
    }
}
