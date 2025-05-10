// SPDX-License-License: MIT
pragma solidity ^0.8.20;

interface IArtistToken {
  event MaxSupplyUpdated(uint256 newMaxSupply);

  function mint(address to, uint256 amount) external payable;
  function burn(address from, uint256 amount) external;
  function mintFromAction(address to, uint256 amount) external payable;

  function setMaxSupply(uint256 newMaxSupply) external;
  function maxSupply() external view returns (uint256);
  function profileId() external view returns (uint256);
}
