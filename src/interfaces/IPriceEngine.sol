// SPDX-License-License: MIT
pragma solidity ^0.8.20;

interface IPriceEngine {
  function depositGHO() external payable;
  function getMintPrice(uint256 profileId) external view returns (uint256);
  function updateMetricsAndSI(uint256 profileId) external;
  function calculatePrices(uint256[] calldata profileIds) external returns (uint256[] memory);
}
