// SPDX-License-License: MIT
pragma solidity ^0.8.20;

import '../../src/contracts/ArtistToken.sol';
import '../../src/contracts/ArtistTokenFactory.sol';
import '../../src/contracts/PriceEngine.sol';

import '../../src/mocks/MockFollowNFT.sol';
import '../../src/mocks/MockLensHub.sol';
import '../../src/mocks/MockOracle.sol';

import '@openzeppelin/contracts/access/Ownable.sol';
import 'forge-std/Test.sol';

contract ArtistTokenFactoryTest is Test {
  ArtistTokenFactory factory;
  MockLensHub lensHub;
  MockFollowNFT followNFT;
  MockOracle oracle;
  PriceEngine priceEngine;

  address owner = address(0x1);
  address nonOwner = address(0x2);
  uint256 profileId = 1;

  function setUp() public {
    vm.deal(owner, 1000 ether);

    lensHub = new MockLensHub();
    followNFT = new MockFollowNFT();
    oracle = new MockOracle();

    lensHub.setProfile(profileId, owner);
    lensHub.setFollowNFT(profileId, address(followNFT));
    lensHub.setPubCount(profileId, 10);
    followNFT.setTotalSupply(100);
    oracle.setMetrics(profileId, 1000, 50, 500, 20);

    priceEngine = new PriceEngine(address(lensHub), address(oracle), address(0), owner);
    factory = new ArtistTokenFactory(address(lensHub), owner);
  }

  function testCreateArtistToken() public {
    vm.prank(owner);
    address token = factory.createArtistToken(profileId, 'Test Token', 'TST', 1_000_000, address(priceEngine));

    assertTrue(token != address(0));
    assertEq(factory.profileIdToToken(profileId), token);

    ArtistToken artistToken = ArtistToken(token);
    assertEq(artistToken.name(), 'Test Token');
    assertEq(artistToken.symbol(), 'TST');
    assertEq(artistToken.maxSupply(), 1_000_000);
    assertEq(artistToken.profileId(), profileId);
    assertEq(artistToken.owner(), owner);
  }

  function testCreateArtistTokenInvalidProfile() public {
    uint256 invalidProfileId = 2;
    vm.prank(owner);
    vm.expectRevert('Invalid Lens profile');
    factory.createArtistToken(invalidProfileId, 'Test Token', 'TST', 1_000_000, address(priceEngine));
  }

  function testCreateArtistTokenAlreadyExists() public {
    vm.prank(owner);
    factory.createArtistToken(profileId, 'Test Token', 'TST', 1_000_000, address(priceEngine));

    vm.prank(owner);
    vm.expectRevert('Token already exists');
    factory.createArtistToken(profileId, 'Test Token 2', 'TST2', 1_000_000, address(priceEngine));
  }

  function testCreateArtistTokenSupplyTooHigh() public {
    vm.prank(owner);
    vm.expectRevert('Supply too high');
    factory.createArtistToken(profileId, 'Test Token', 'TST', 1_000_001, address(priceEngine));
  }

  function testCreateArtistTokenNonOwner() public {
    vm.prank(nonOwner);
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, nonOwner));
    factory.createArtistToken(profileId, 'Test Token', 'TST', 1_000_000, address(priceEngine));
  }
}
