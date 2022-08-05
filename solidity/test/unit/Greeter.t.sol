// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <0.9.0;

import 'test/utils/DSTestFull.sol';
import 'contracts/Greeter.sol';

abstract contract Base is DSTestFull {
    address owner = label('owner');
    IERC20 token = IERC20(mockContract('token'));
    string initialGreeting = 'hola';
    bytes32 emptyString = keccak256(bytes(''));
    Greeter greeter;

    function setUp() public virtual {
        vm.prank(owner);
        greeter = new Greeter(initialGreeting, token);
    }
}

contract Unit_Greeter_Constructor is Base {
    function test_OwnerSet(address owner) public {
        vm.prank(owner);
        greeter = new Greeter(initialGreeting, token);

        assertEq(greeter.OWNER(), owner);
    }

    function test_TokenSet(IERC20 token) public {
        greeter = new Greeter(initialGreeting, token);

        assertEq(address(greeter.token()), address(token));
    }

    function test_GreetingSet(string memory greeting) public {
        vm.assume(keccak256(bytes(greeting)) != emptyString);

        greeter = new Greeter(greeting, token);
        assertEq(greeting, greeter.greeting());
    }
}

contract Unit_Greeter_SetGreeting is Base {
    event GreetingSet(string _greeting);

    function setUp() public override {
        super.setUp();
        vm.startPrank(owner);
    }

    function test_RevertIfNotOwner(address caller, string memory greeting) public {
        vm.assume(keccak256(bytes(greeting)) != emptyString);
        vm.assume(caller != owner);

        vm.stopPrank();
        vm.prank(caller);

        vm.expectRevert(IGreeter.Greeter_OnlyOwner.selector);
        greeter.setGreeting(greeting);
    }

    function test_RevertIfEmptyGreeting() public {
        vm.expectRevert(IGreeter.Greeter_InvalidGreeting.selector);
        greeter.setGreeting('');
    }

    function test_SetGreeting(string memory greeting) public {
        vm.assume(keccak256(bytes(greeting)) != emptyString);
        greeter.setGreeting(greeting);

        assertEq(greeting, greeter.greeting());
    }

    function test_EmitEvent(string memory greeting) public {
        vm.assume(keccak256(bytes(greeting)) != emptyString);

        expectEmitNoIndex();
        emit GreetingSet(greeting);

        greeter.setGreeting(greeting);
    }
}

contract Unit_Greeter_Greet is Base {
    function test_GetGreeting() public {
        vm.mockCall(address(token), abi.encodeWithSelector(IERC20.balanceOf.selector), abi.encode(0));

        (string memory greeting,) = greeter.greet();
        assertEq(initialGreeting, greeting);
    }

    function test_GetTokenBalance(address caller, uint256 balance) public {
        vm.mockCall(address(token), abi.encodeWithSelector(IERC20.balanceOf.selector, caller), abi.encode(balance));

        vm.prank(caller);
        (, uint256 greetBalance) = greeter.greet();
        assertEq(balance, greetBalance);
    }
}
