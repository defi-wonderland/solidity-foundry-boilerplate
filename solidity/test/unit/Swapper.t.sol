// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from 'forge-std/Test.sol';
import {Swapper} from '../../contracts/Swapper.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

error InsufficientLiquidity();
error ZeroBalance();

contract SwapperTest is Test {
  Swapper public swapper;

  IERC20 fromToken;
  IERC20 toToken;

  address alice = makeAddr('alice');
  address bob = makeAddr('bob');
  address eve = makeAddr('eve');

  uint256 constant LIQUIDITY = 100e18;

  function setUp() public {
    vm.createSelectFork(vm.envString('MAINNET_RPC'));
    fromToken = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC token
    toToken = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F); // DAI token

    swapper = new Swapper(address(fromToken), address(toToken));

    deal(address(toToken), address(this), LIQUIDITY);
    toToken.approve(address(swapper), LIQUIDITY);
    swapper.provideLiquidity(LIQUIDITY);

    deal(address(fromToken), alice, 1e18);
    deal(address(fromToken), bob, 2e18);
    deal(address(fromToken), eve, 10e18);
  }

  // Basic check that tokens are correctly provided to the swapper when providing
  function testProvide() public {
    vm.startPrank(alice);
    fromToken.approve(address(swapper), 1e18);
    swapper.provide(1e18);

    assertEq(fromToken.balanceOf(address(swapper)), 1e18);
  }

  // User should be able to get a refund for any deposited tokens not yet swapped
  function testRefund() public {
    vm.startPrank(alice);
    fromToken.approve(address(swapper), 1e18);
    uint256 _swapId = swapper.provide(1e18);
    swapper.withdraw(_swapId);

    assertEq(fromToken.balanceOf(alice), 1e18);
  }

  // Alice should be allowed to swap her tokens and receive the correct amount of toTokens
  // Contract deployer receives all excess tokens
  function testSwap() public {
    vm.prank(alice);
    fromToken.approve(address(swapper), 1e18);

    vm.prank(alice);
    uint256 _swapId = swapper.provide(1e18);

    swapper.swap();

    vm.prank(alice);
    swapper.withdraw(_swapId);

    assertEq(toToken.balanceOf(alice), 1e18);
    assertEq(fromToken.balanceOf(address(this)), 1e18);
  }

  // Testing swaps over multiple epochs
  function testMultipleEpochs() public {
    vm.prank(alice);
    fromToken.approve(address(swapper), 1e18);

    vm.prank(alice);
    uint256 _swapId = swapper.provide(1e18);

    swapper.swap();

    vm.prank(alice);
    swapper.withdraw(_swapId);

    vm.prank(bob);
    fromToken.approve(address(swapper), 1e18);

    vm.prank(bob);
    _swapId = swapper.provide(1e18);

    swapper.swap();

    vm.prank(bob);
    swapper.withdraw(_swapId);

    assertEq(toToken.balanceOf(alice), 1e18);
    assertEq(toToken.balanceOf(bob), 1e18);
    assertEq(fromToken.balanceOf(address(this)), 2e18);
  }

  // Testing multiple swaps over same epoch
  // alice and bob do the swap and get toTokens
  // eve gets a refund
  function testMultipleSwaps() public {
    vm.prank(alice);
    fromToken.approve(address(swapper), 1e18);

    vm.prank(alice);
    uint256 _swapId = swapper.provide(1e18);

    vm.prank(bob);
    fromToken.approve(address(swapper), 1e18);

    vm.prank(bob);
    _swapId = swapper.provide(1e18);

    vm.prank(eve);
    fromToken.approve(address(swapper), 1e18);

    vm.prank(eve);
    _swapId = swapper.provide(1e18);

    vm.prank(eve);
    swapper.withdraw(_swapId);

    swapper.swap();

    vm.prank(alice);
    swapper.withdraw(_swapId);

    vm.prank(bob);
    swapper.withdraw(_swapId);

    assertEq(toToken.balanceOf(alice), 1e18);
    assertEq(toToken.balanceOf(bob), 1e18);
    assertEq(toToken.balanceOf(eve), 0);
    assertEq(fromToken.balanceOf(address(this)), 2e18);
  }

  // Users cannot provide more tokens to be swapped than the total current liquidity
  function testLiquidity() public {
    deal(address(fromToken), alice, LIQUIDITY + 1);

    vm.startPrank(alice);
    fromToken.approve(address(swapper), LIQUIDITY + 1);
    swapper.provide(LIQUIDITY);

    vm.expectRevert();
    swapper.provide(1);
  }

  function testFuzz_swap(uint256 _amount, bool swap) public {
    _amount = bound(_amount, 1, LIQUIDITY);
    deal(address(fromToken), alice, _amount);

    vm.prank(alice);
    fromToken.approve(address(swapper), _amount);

    vm.prank(alice);

    uint256 _swapId = swapper.provide(_amount);

    if (swap) {
      swapper.swap();
    }

    vm.prank(alice);
    swapper.withdraw(_swapId);

    if (swap) {
      assertEq(fromToken.balanceOf(address(this)), _amount);
      assertEq(toToken.balanceOf(alice), _amount);
    } else {
      assertEq(fromToken.balanceOf(alice), _amount);
    }
  }
}
