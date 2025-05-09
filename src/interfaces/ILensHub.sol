// SPDX-License-License: MIT
pragma solidity ^0.8.20;

interface ILensHub {
  function getFollowNFT(uint256 profileId) external view returns (address);
  function getPubCount(uint256 profileId) external view returns (uint256);
  function getProfile(uint256 profileId) external view returns (address);
}
