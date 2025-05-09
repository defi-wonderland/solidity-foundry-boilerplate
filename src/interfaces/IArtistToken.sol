// SPDX-License-License: MIT
pragma solidity ^0.8.20;

interface IArtistToken {
  event MaxSupplyUpdated(uint256 newMaxSupply);

  function mint(address to, uint256 amount) external payable;
  function burn(address from, uint256 amount) external;
  function setMaxSupply(uint256 newMaxSupply) external;
  function withdrawGHO(address to, uint256 amount) external;
  function maxSupply() external view returns (uint256);
  function profileId() external view returns (uint256);
}
