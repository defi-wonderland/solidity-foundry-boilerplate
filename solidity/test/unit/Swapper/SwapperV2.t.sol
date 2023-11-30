// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from 'forge-std/Test.sol';
import {SwapperV2} from '../../../contracts/Swapper/SwapperV2.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

error InsufficientLiquidity();
error ZeroBalance();

contract SwapperV2Test is Test {
  SwapperV2 public swapper;

  IERC20 constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  IERC20 constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

  address alice = makeAddr('alice');
  address bob = makeAddr('bob');
  address eve = makeAddr('eve');

  uint256 constant LIQUIDITY = 100e18;

  function setUp() public {
    vm.createSelectFork(vm.envString('MAINNET_RPC'));

    swapper = new SwapperV2();

    deal(address(this), LIQUIDITY);

    deal(alice, 1e18);
    deal(bob, 2e18);
    deal(eve, 10e18);
  }

  //Basic check that tokens are correctly provided to the swapper when providing
  function testProvide() public {
    vm.startPrank(alice);
    swapper.provide{value: 1e18}();

    assertEq(address(swapper).balance, 1e18);
  }

  // User should be able to get a refund for any deposited tokens not yet swapped
  function testRefund() public {
    vm.startPrank(alice);
    uint256 _swapId = swapper.provide{value: 1e18}();
    swapper.withdraw(_swapId);

    assertEq(alice.balance, 1e18);
  }

  // Alice should be allowed to swap her tokens and receive the correct amount of toTokens
  // Contract deployer receives all excess tokens
  function testSwap() public {
    vm.prank(alice);

    uint256 _swapId = swapper.provide{value: 1e18}();

    swapper.swap();

    vm.prank(alice);
    swapper.withdraw(_swapId);

    assertGt(DAI.balanceOf(alice), 0);
    assertEq(DAI.balanceOf(address(this)), 0);
  }

  // Testing swaps over multiple epochs
  function testMultipleEpochs() public {
    vm.prank(alice);

    uint256 _swapId = swapper.provide{value: 1e18}();

    swapper.swap();

    vm.prank(alice);
    swapper.withdraw(_swapId);

    vm.prank(bob);
    _swapId = swapper.provide{value: 1e18}();

    swapper.swap();

    vm.prank(bob);
    swapper.withdraw(_swapId);

    assertGt(DAI.balanceOf(alice), 0);
    assertGt(DAI.balanceOf(bob), 0);
    assertEq(DAI.balanceOf(address(this)), 0);
  }

  // Testing multiple swaps over same epoch
  // alice and bob do the swap and get toTokens
  // eve gets a refund
  function testMultipleSwaps() public {
    vm.prank(alice);

    uint256 _swapId = swapper.provide{value: 1e18}();

    vm.prank(bob);

    _swapId = swapper.provide{value: 1e18}();

    vm.prank(eve);

    _swapId = swapper.provide{value: 1e18}();

    vm.prank(eve);
    swapper.withdraw(_swapId);

    swapper.swap();

    vm.prank(alice);
    swapper.withdraw(_swapId);

    vm.prank(bob);
    swapper.withdraw(_swapId);

    assertGt(DAI.balanceOf(alice), 0);
    assertGt(DAI.balanceOf(bob), 0);
    assertEq(eve.balance, 10e18);
    assertEq(DAI.balanceOf(address(this)), 0);
  }

  function testFuzz_swap(uint256 _amount, bool swap) public {
    _amount = bound(_amount, 1, 1e21);
    deal(alice, _amount);

    vm.prank(alice);

    uint256 _swapId = swapper.provide{value: _amount}();

    if (swap) {
      swapper.swap();
    }

    vm.prank(alice);
    swapper.withdraw(_swapId);

    if (swap) {
      assertEq(DAI.balanceOf(address(this)), 0);
      assertGt(DAI.balanceOf(alice), 0);
    } else {
      assertEq(alice.balance, _amount);
    }
  }
}
