// SPDX-License-License: MIT
pragma solidity ^0.8.20;

interface ILensFluenceTippingModule {
  function configure(uint256 profileId, bytes calldata data) external returns (bytes memory);

  function execute(
    uint256 profileId,
    address transactionExecutor,
    bytes calldata data
  ) external payable returns (bytes memory);

  function disable(uint256 profileId, bytes calldata data) external returns (bytes memory);
}
