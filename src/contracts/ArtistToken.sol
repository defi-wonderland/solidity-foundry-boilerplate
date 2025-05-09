// SPDX-License-License: MIT
pragma solidity ^0.8.20;

import '../interfaces/IArtistToken.sol';
import '../interfaces/IPriceEngine.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

contract ArtistToken is ERC20, Ownable, IArtistToken {
  using Math for uint256;

  uint256 public override maxSupply;
  IPriceEngine public priceEngine;
  uint256 public override profileId;

  constructor(
    string memory name,
    string memory symbol,
    uint256 _maxSupply,
    address _priceEngine,
    uint256 _profileId,
    address initialOwner
  ) ERC20(name, symbol) Ownable(initialOwner) {
    require(_maxSupply <= 1_000_000, 'Supply too high');
    maxSupply = _maxSupply;
    priceEngine = IPriceEngine(_priceEngine);
    profileId = _profileId;
  }

  function mint(address to, uint256 amount) external payable override {
    require(totalSupply() + amount <= maxSupply, 'Exceeds max supply');
    uint256 pricePerToken = priceEngine.getMintPrice(profileId);
    uint256 cost = amount.mulDiv(pricePerToken, 1e18);
    require(msg.value >= cost, 'Insufficient GHO');
    if (msg.value > cost) {
      payable(msg.sender).transfer(msg.value - cost);
    }
    _mint(to, amount);
    priceEngine.updateMetricsAndSI(profileId);
  }

  function burn(address from, uint256 amount) external override {
    require(balanceOf(from) >= amount, 'Insufficient balance');
    uint256 pricePerToken = priceEngine.getMintPrice(profileId);
    uint256 ghoToTransfer = amount.mulDiv(pricePerToken, 1e18);
    require(address(this).balance >= ghoToTransfer, 'Insufficient GHO in contract');
    _burn(from, amount);
    payable(from).transfer(ghoToTransfer);
    priceEngine.updateMetricsAndSI(profileId);
  }

  function setMaxSupply(uint256 newMaxSupply) external override onlyOwner {
    require(newMaxSupply >= totalSupply(), 'Cannot reduce below current supply');
    require(newMaxSupply <= 10_000_000, 'New supply too high');
    maxSupply = newMaxSupply;
    emit MaxSupplyUpdated(newMaxSupply);
  }

  function withdrawGHO(address to, uint256 amount) external override onlyOwner {
    require(amount <= address(this).balance, 'Insufficient balance');
    payable(to).transfer(amount);
  }
}
