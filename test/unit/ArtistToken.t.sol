// SPDX-License-License: MIT
pragma solidity ^0.8.20;

import '../../src/contracts/ArtistToken.sol';
import '../../src/contracts/ArtistTokenFactory.sol';
import '../../src/contracts/PriceEngine.sol';

import '../../src/mocks/MockFollowNFT.sol';
import '../../src/mocks/MockLensHub.sol';
import '../../src/mocks/MockOracle.sol';
import 'forge-std/Test.sol';

contract ArtistTokenTest is Test {
  ArtistToken token;
  PriceEngine priceEngine;
  MockLensHub lensHub;
  MockFollowNFT followNFT;
  MockOracle oracle;

  address owner = address(0x1);
  address user = address(0x2);
  uint256 profileId = 1;
  uint256 maxSupply = 1_000_000;

  function setUp() public {
    vm.deal(owner, 1000 ether);
    vm.deal(user, 1000 ether);

    lensHub = new MockLensHub();
    followNFT = new MockFollowNFT();
    oracle = new MockOracle();

    lensHub.setProfile(profileId, owner);
    lensHub.setFollowNFT(profileId, address(followNFT));
    lensHub.setPubCount(profileId, 10);
    followNFT.setTotalSupply(100);
    oracle.setMetrics(profileId, 1000, 50, 500, 20);

    ArtistTokenFactory factory = new ArtistTokenFactory(address(lensHub), owner);

    priceEngine = new PriceEngine(address(lensHub), address(oracle), address(factory), owner);
    vm.prank(owner);
    priceEngine.depositGHO{value: 100 ether}();

    vm.prank(owner);
    token = ArtistToken(factory.createArtistToken(profileId, 'Test Token', 'TST', maxSupply, address(priceEngine)));
  }

  function testConstructor() public {
    assertEq(token.name(), 'Test Token');
    assertEq(token.symbol(), 'TST');
    assertEq(token.maxSupply(), maxSupply);
    assertEq(token.profileId(), profileId);
    assertEq(token.owner(), owner);
    assertEq(address(token.priceEngine()), address(priceEngine));
  }

  function testMint() public {
    uint256 amount = 100;
    uint256 pricePerToken = priceEngine.getMintPrice(profileId);
    uint256 cost = (amount * pricePerToken) / 1e18;

    vm.prank(user);
    token.mint{value: cost}(user, amount);

    assertEq(token.balanceOf(user), amount);
    assertEq(token.totalSupply(), amount);
    assertEq(address(token).balance, cost);
  }

  function testMintInsufficientGHO() public {
    uint256 amount = 100;
    uint256 pricePerToken = priceEngine.getMintPrice(profileId);
    uint256 cost = (amount * pricePerToken) / 1e18;

    vm.prank(user);
    vm.expectRevert('Insufficient GHO');
    token.mint{value: cost / 2}(user, amount);
  }

  function testMintExceedsMaxSupply() public {
    uint256 amount = maxSupply + 1;
    uint256 pricePerToken = priceEngine.getMintPrice(profileId);
    uint256 cost = (amount * pricePerToken) / 1e18;

    vm.prank(user);
    vm.expectRevert('Exceeds max supply');
    token.mint{value: cost}(user, amount);
  }

  function testBurn() public {
    uint256 amount = 100;
    uint256 pricePerToken = priceEngine.getMintPrice(profileId);
    uint256 cost = (amount * pricePerToken) / 1e18;

    vm.prank(user);
    token.mint{value: cost}(user, amount);

    uint256 userBalanceBefore = user.balance;
    vm.prank(user);
    token.burn(user, amount);

    assertEq(token.balanceOf(user), 0);
    assertEq(token.totalSupply(), 0);
    assertApproxEqAbs(user.balance, userBalanceBefore + cost, 1 wei);
  }

  function testBurnInsufficientBalance() public {
    uint256 amount = 100;
    vm.prank(user);
    vm.expectRevert('Insufficient balance');
    token.burn(user, amount);
  }

  function testSetMaxSupply() public {
    uint256 newMaxSupply = 2_000_000;
    vm.prank(owner);
    token.setMaxSupply(newMaxSupply);

    assertEq(token.maxSupply(), newMaxSupply);
  }

  function testSetMaxSupplyBelowTotalSupply() public {
    uint256 amount = 100;
    uint256 pricePerToken = priceEngine.getMintPrice(profileId);
    uint256 cost = (amount * pricePerToken) / 1e18;

    vm.prank(user);
    token.mint{value: cost}(user, amount);

    vm.prank(owner);
    vm.expectRevert('Cannot reduce below current supply');
    token.setMaxSupply(amount - 1);
  }

  function testSetMaxSupplyTooHigh() public {
    vm.prank(owner);
    vm.expectRevert('New supply too high');
    token.setMaxSupply(10_000_001);
  }
}
