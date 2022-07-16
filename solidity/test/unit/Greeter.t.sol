// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <0.9.0;

import 'test/utils/DSTestPlusPlus.sol';
import 'contracts/Greeter.sol';

abstract contract Base is DSTestPlusPlus {
    address owner = label('owner');
    string initialGreeting = 'hola';
    Greeter greeter;

    function setUp() public virtual {
        vm.prank(owner);
        greeter = new Greeter(initialGreeting);
    }
}

contract Unit_Greeter_Constructor is Base {
    function test_OwnerSet(address owner) public {
        vm.prank(owner);
        greeter = new Greeter(initialGreeting);

        assertEq(greeter.OWNER(), owner);
    }

    function test_GreetingSet(string memory greeting) public {
        greeter = new Greeter(greeting);

        string memory bleh = string(abi.encodePacked(vm.load(address(greeter), bytes32(uint256(0)))));
        assertEq(bleh, greeting);
    }
}

contract Unit_Greeter_Greet is Base {}

contract Unit_Greeter_SetGreeting is Base {}
