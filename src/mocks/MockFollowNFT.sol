// SPDX-License-License: MIT
pragma solidity ^0.8.20;

import '../interfaces/IFollowNFT.sol';

contract MockFollowNFT is IFollowNFT {
  uint256 public override totalSupply;

  function setTotalSupply(uint256 _totalSupply) external {
    totalSupply = _totalSupply;
  }
}
