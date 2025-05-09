// SPDX-License-License: MIT
pragma solidity ^0.8.20;

import '../../src/interfaces/ILensHub.sol';

contract MockLensHub is ILensHub {
  mapping(uint256 => address) public profiles;
  mapping(uint256 => address) public followNFTs;
  mapping(uint256 => uint256) public pubCounts;

  function setProfile(uint256 profileId, address owner) external {
    profiles[profileId] = owner;
  }

  function setFollowNFT(uint256 profileId, address followNFT) external {
    followNFTs[profileId] = followNFT;
  }

  function setPubCount(uint256 profileId, uint256 count) external {
    pubCounts[profileId] = count;
  }

  function getFollowNFT(uint256 profileId) external view override returns (address) {
    return followNFTs[profileId];
  }

  function getPubCount(uint256 profileId) external view override returns (uint256) {
    return pubCounts[profileId];
  }

  function getProfile(uint256 profileId) external view override returns (address) {
    return profiles[profileId];
  }
}
