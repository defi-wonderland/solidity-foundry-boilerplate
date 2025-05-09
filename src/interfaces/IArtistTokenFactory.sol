// SPDX-License-License: MIT
pragma solidity ^0.8.20;

interface IArtistTokenFactory {
  function createArtistToken(
    uint256 profileId,
    string memory name,
    string memory symbol,
    uint256 maxSupply,
    address priceEngine
  ) external returns (address);

  function profileIdToToken(uint256 profileId) external view returns (address);

  event TokenCreated(uint256 profileId, address token);
}
