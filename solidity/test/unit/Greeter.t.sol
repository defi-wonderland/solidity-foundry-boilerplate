// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';
import {DSTestFull} from 'test/utils/DSTestFull.sol';
import {Greeter, IGreeter} from 'contracts/Greeter.sol';
import {InternalCallsWatcherExtension, InternalCallsWatcher} from 'test/utils/InternalCallsWatcher.sol';

abstract contract Base is DSTestFull {
  address internal _owner = _label('owner');
  IERC20 internal _token = IERC20(_mockContract('token'));
  string internal _initialGreeting = 'hola';
  bytes32 internal _emptyString = keccak256(bytes(''));
  Greeter internal _greeter;

  function setUp() public virtual {
    vm.prank(_owner);
    _greeter = new GreeterForInternalCallsTest(_initialGreeting, _token);
  }
}

contract GreeterForInternalCallsTest is InternalCallsWatcherExtension, Greeter {
  constructor(string memory _greeting, IERC20 _token) Greeter(_greeting, _token) {}

  function _updateLastGreetingSetTime(uint256 _timestamp) internal override {
    calledInternal(abi.encodeWithSignature('_updateLastGreetingSetTime(uint256)', _timestamp));
    super._updateLastGreetingSetTime(_timestamp);
  }
}

contract UnitGreeterConstructor is Base {
  function test_OwnerSet(address _owner) public {
    vm.prank(_owner);
    _greeter = new Greeter(_initialGreeting, _token);

    assertEq(_greeter.OWNER(), _owner);
  }

  function test_TokenSet(IERC20 _token) public {
    _greeter = new Greeter(_initialGreeting, _token);

    assertEq(address(_greeter.token()), address(_token));
  }

  function test_GreetingSet(string memory _greeting) public {
    vm.assume(keccak256(bytes(_greeting)) != _emptyString);

    _greeter = new Greeter(_greeting, _token);
    assertEq(_greeting, _greeter.greeting());
  }
}

contract UnitGreeterSetGreeting is Base {
  event GreetingSet(string _greeting);

  address internal _watcher;

  function setUp() public override {
    super.setUp();
    _watcher = address((GreeterForInternalCallsTest(address(_greeter)).watcher()));
    vm.startPrank(_owner);
  }

  function test_RevertIfNotOwner(address _caller, string memory _greeting) public {
    vm.assume(keccak256(bytes(_greeting)) != _emptyString);
    vm.assume(_caller != _owner);

    vm.stopPrank();
    vm.prank(_caller);

    vm.expectRevert(IGreeter.Greeter_OnlyOwner.selector);
    _greeter.setGreeting(_greeting);
  }

  function test_RevertIfEmptyGreeting() public {
    vm.expectRevert(IGreeter.Greeter_InvalidGreeting.selector);
    _greeter.setGreeting('');
  }

  function test_SetGreeting(string memory _greeting) public {
    vm.assume(keccak256(bytes(_greeting)) != _emptyString);
    _greeter.setGreeting(_greeting);

    assertEq(_greeting, _greeter.greeting());
  }

  function test_EmitEvent(string memory _greeting) public {
    vm.assume(keccak256(bytes(_greeting)) != _emptyString);

    _expectEmitNoIndex();
    emit GreetingSet(_greeting);

    _greeter.setGreeting(_greeting);
  }

  function test_Call_Internal_UpdateLastGreetingSetTime(uint256 _timestamp) public {
    vm.warp(_timestamp);
    vm.expectCall(
      _watcher,
      abi.encodeWithSelector(
        InternalCallsWatcher.calledInternal.selector,
        abi.encodeWithSignature('_updateLastGreetingSetTime(uint256)', _timestamp)
      )
    );

    _greeter.setGreeting(_initialGreeting);
  }
}

contract UnitGreeterGreet is Base {
  function test_GetGreeting() public {
    vm.mockCall(address(_token), abi.encodeWithSelector(IERC20.balanceOf.selector), abi.encode(0));

    (string memory _greeting,) = _greeter.greet();
    assertEq(_initialGreeting, _greeting);
  }

  function test_GetTokenBalance(address _caller, uint256 _balance) public {
    vm.mockCall(address(_token), abi.encodeWithSelector(IERC20.balanceOf.selector, _caller), abi.encode(_balance));

    vm.prank(_caller);
    (, uint256 _greetBalance) = _greeter.greet();
    assertEq(_balance, _greetBalance);
  }
}
