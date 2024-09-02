// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Greeter, IGreeter} from 'contracts/Greeter.sol';
import {Test} from 'forge-std/Test.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';

contract UnitGreeter is Test {
  address internal _owner = makeAddr('owner');
  IERC20 internal _token = IERC20(makeAddr('token'));
  uint256 internal _initialBalance = 100;
  string internal _initialGreeting = 'hola';

  Greeter internal _greeter;

  event GreetingSet(string _greeting);

  function setUp() external {
    vm.prank(_owner);
    _greeter = new Greeter(_initialGreeting, _token);

    vm.etch(address(_token), new bytes(0x1));
  }

  function test_EmptyTestExample() external {
    // it does nothing
    vm.skip(true);
  }

  function test_ConstructorWhenPassingValidGreetingString() external {
    vm.prank(_owner);

    // it deploys
    _greeter = new Greeter(_initialGreeting, _token);

    // it sets the greeting string
    assertEq(_greeter.greeting(), _initialGreeting);

    // it sets the owner as sender
    assertEq(_greeter.OWNER(), _owner);

    // it sets the token used
    assertEq(address(_greeter.token()), address(_token));
  }

  function test_ConstructorWhenPassingAnEmptyGreetingString() external {
    vm.prank(_owner);

    // it reverts
    vm.expectRevert(IGreeter.Greeter_InvalidGreeting.selector);
    _greeter = new Greeter('', _token);
  }

  function test_GreetWhenCalled() external {
    vm.mockCall(address(_token), abi.encodeWithSelector(IERC20.balanceOf.selector), abi.encode(_initialBalance));
    vm.expectCall(address(_token), abi.encodeWithSelector(IERC20.balanceOf.selector));
    (string memory _greet, uint256 _balance) = _greeter.greet();

    // it returns the greeting string
    assertEq(_greet, _initialGreeting);

    // it returns the token balance of the contract
    assertEq(_balance, _initialBalance);
  }

  modifier whenCalledByTheOwner() {
    vm.startPrank(_owner);
    _;
    vm.stopPrank();
  }

  function test_SetGreetingWhenPassingAValidGreetingString() external whenCalledByTheOwner {
    string memory _newGreeting = 'hello';

    // it emit GreetingSet
    vm.expectEmit(true, true, true, true, address(_greeter));
    emit GreetingSet(_newGreeting);

    _greeter.setGreeting(_newGreeting);

    // it sets the greeting string
    assertEq(_greeter.greeting(), _newGreeting);
  }

  function test_SetGreetingWhenPassingAnEmptyGreetingString() external whenCalledByTheOwner {
    // it reverts
    vm.expectRevert(IGreeter.Greeter_InvalidGreeting.selector);
    _greeter.setGreeting('');
  }

  function test_SetGreetingWhenCalledByANon_owner(
    address _caller
  ) external {
    vm.assume(_caller != _owner);
    vm.prank(_caller);

    // it reverts
    vm.expectRevert(IGreeter.Greeter_OnlyOwner.selector);
    _greeter.setGreeting('new greeting');
  }
}
