// SPDX-License-License: MIT
pragma solidity ^0.8.20;

import "./ArtistToken.sol";
import "../interfaces/IArtistTokenFactory.sol";
import "../interfaces/ILensHub.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtistTokenFactory is Ownable, IArtistTokenFactory {
    address public lensHub;
    address public priceEngine;
    mapping(uint256 => address) public override profileIdToToken;

    constructor(address _lensHub, address _priceEngine, address initialOwner) Ownable(initialOwner) {
        lensHub = _lensHub;
        priceEngine = _priceEngine;
    }

    function createArtistToken(
        uint256 profileId,
        string memory name,
        string memory symbol,
        uint256 maxSupply
    ) external override onlyOwner returns (address) {
        require(profileIdToToken[profileId] == address(0), "Token already exists");
        require(maxSupply <= 1_000_000, "Supply too high");
        require(isValidLensProfile(profileId), "Invalid Lens profile");

        ArtistToken token = new ArtistToken(name, symbol, maxSupply, priceEngine, profileId, owner());
        profileIdToToken[profileId] = address(token);
        emit TokenCreated(profileId, address(token));
        return address(token);
    }

    function isValidLensProfile(uint256 profileId) internal view returns (bool) {
        return ILensHub(lensHub).getProfile(profileId) != address(0);
    }
}