// SPDX-License-License: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IArtistTokenFactory.sol";
import "../interfaces/IArtistToken.sol";
import "../interfaces/ILensHub.sol";
import "../interfaces/IFollowNFT.sol";
import "../interfaces/IOracle.sol";
import "../interfaces/IPriceEngine.sol";

contract PriceEngine is Ownable, IPriceEngine {
    using Math for uint256;

    address public lensHub;
    address public oracle;
    IArtistTokenFactory public factory;
    uint256 public treasuryGHO;

    mapping(uint256 => uint256) public prevRawValues;
    mapping(uint256 => uint256) public prevLensFollowers;
    mapping(uint256 => uint256) public prevLensPublications;
    mapping(uint256 => uint256) public prevIgFollowers;
    mapping(uint256 => uint256) public prevIgPosts;
    mapping(uint256 => uint256) public prevYtSubscribers;
    mapping(uint256 => uint256) public prevYtVideos;

    uint256 public constant LENS_FOLLOWER_WEIGHT = 0.4e18;
    uint256 public constant IG_FOLLOWER_WEIGHT = 0.1e18;
    uint256 public constant YT_SUBSCRIBER_WEIGHT = 0.1e18;
    uint256 public constant LENS_PUBLICATION_WEIGHT = 0.2e18;
    uint256 public constant IG_POST_WEIGHT = 0.1e18;
    uint256 public constant YT_VIDEO_WEIGHT = 0.1e18;
    uint256 public constant MAX_SI = 10e18;

    constructor(
        address _lensHub,
        address _oracle,
        address _factory,
        address initialOwner
    ) Ownable(initialOwner) {
        lensHub = _lensHub;
        oracle = _oracle;
        factory = IArtistTokenFactory(_factory);
        treasuryGHO = 0;
    }

    function depositGHO() external override payable {
        treasuryGHO += msg.value;
    }

    function getMintPrice(uint256 profileId) external override view returns (uint256) {
        uint256 si = calculateSuccessIndex(profileId);
        uint256 prevRawValue = prevRawValues[profileId] == 0 ? 1e18 : prevRawValues[profileId];
        uint256 rawValue = prevRawValue.mulDiv(si, 1e18);

        address token = factory.profileIdToToken(profileId);
        uint256 supply = token != address(0) ? IERC20(token).totalSupply() : 0;
        uint256 requiredGHO = rawValue.mulDiv(supply, 1e18);
        uint256 scalingFactor = requiredGHO == 0 ? 1e18 : treasuryGHO.mulDiv(1e18, requiredGHO);
        if (scalingFactor > 1e18) scalingFactor = 1e18;

        return rawValue.mulDiv(scalingFactor, 1e18);
    }

    function updateMetricsAndSI(uint256 profileId) external override {
        updateMetrics(profileId);
        uint256 si = calculateSuccessIndex(profileId);
        uint256 prevRawValue = prevRawValues[profileId] == 0 ? 1e18 : prevRawValues[profileId];
        prevRawValues[profileId] = prevRawValue.mulDiv(si, 1e18);
    }

    function calculatePrices(uint256[] calldata profileIds) external override onlyOwner returns (uint256[] memory prices) {
        uint256 totalRequiredGHO = 0;
        uint256[] memory rawValues = new uint256[](profileIds.length);
        prices = new uint256[](profileIds.length);

        for (uint256 i = 0; i < profileIds.length; i++) {
            uint256 profileId = profileIds[i];
            uint256 si = calculateSuccessIndex(profileId);
            uint256 prevRawValue = prevRawValues[profileId] == 0 ? 1e18 : prevRawValues[profileId];
            rawValues[i] = prevRawValue.mulDiv(si, 1e18);

            address token = factory.profileIdToToken(profileId);
            require(token != address(0), "Token does not exist");
            uint256 supply = IERC20(token).totalSupply();
            totalRequiredGHO += rawValues[i].mulDiv(supply, 1e18);

            prevRawValues[profileId] = rawValues[i];
            updateMetrics(profileId);
        }

        uint256 scalingFactor = totalRequiredGHO == 0 ? 1e18 : treasuryGHO.mulDiv(1e18, totalRequiredGHO);
        if (scalingFactor > 1e18) scalingFactor = 1e18;

        for (uint256 i = 0; i < profileIds.length; i++) {
            prices[i] = rawValues[i].mulDiv(scalingFactor, 1e18);
        }
    }

    function calculateSuccessIndex(uint256 profileId) internal view returns (uint256) {
        address followNFT = ILensHub(lensHub).getFollowNFT(profileId);
        uint256 currentLensFollowers = followNFT != address(0) ? IFollowNFT(followNFT).totalSupply() : 0;
        uint256 currentLensPublications = ILensHub(lensHub).getPubCount(profileId);

        (uint256 currentIgFollowers, uint256 currentIgPosts, uint256 currentYtSubscribers, uint256 currentYtVideos) = IOracle(oracle).getMetrics(profileId);

        require(currentLensFollowers <= 1_000_000_000, "Lens followers too high");
        require(currentIgFollowers <= 1_000_000_000, "IG followers too high");
        require(currentYtSubscribers <= 1_000_000_000, "YT subscribers too high");

        uint256 lensFollowerSI = prevLensFollowers[profileId] == 0 ? 1e18 : currentLensFollowers.mulDiv(1e18, prevLensFollowers[profileId]);
        uint256 lensPublicationSI = prevLensPublications[profileId] == 0 ? 1e18 : currentLensPublications.mulDiv(1e18, prevLensPublications[profileId]);
        uint256 igFollowerSI = prevIgFollowers[profileId] == 0 ? 1e18 : currentIgFollowers.mulDiv(1e18, prevIgFollowers[profileId]);
        uint256 igPostSI = prevIgPosts[profileId] == 0 ? 1e18 : currentIgPosts.mulDiv(1e18, prevIgPosts[profileId]);
        uint256 ytSubscriberSI = prevYtSubscribers[profileId] == 0 ? 1e18 : currentYtSubscribers.mulDiv(1e18, prevYtSubscribers[profileId]);
        uint256 ytVideoSI = prevYtVideos[profileId] == 0 ? 1e18 : currentYtVideos.mulDiv(1e18, prevYtVideos[profileId]);

        uint256 si = LENS_FOLLOWER_WEIGHT.mulDiv(lensFollowerSI, 1e18)
            +IG_FOLLOWER_WEIGHT.mulDiv(igFollowerSI, 1e18)
            +YT_SUBSCRIBER_WEIGHT.mulDiv(ytSubscriberSI, 1e18)
            +LENS_PUBLICATION_WEIGHT.mulDiv(lensPublicationSI, 1e18)
            +IG_POST_WEIGHT.mulDiv(igPostSI, 1e18)
            +YT_VIDEO_WEIGHT.mulDiv(ytVideoSI, 1e18);

        return si > MAX_SI ? MAX_SI : si;
    }

    function updateMetrics(uint256 profileId) internal {
        address followNFT = ILensHub(lensHub).getFollowNFT(profileId);
        prevLensFollowers[profileId] = followNFT != address(0) ? IFollowNFT(followNFT).totalSupply() : 0;
        prevLensPublications[profileId] = ILensHub(lensHub).getPubCount(profileId);
        (uint256 igFollowers, uint256 igPosts, uint256 ytSubscribers, uint256 ytVideos) = IOracle(oracle).getMetrics(profileId);
        prevIgFollowers[profileId] = igFollowers;
        prevIgPosts[profileId] = igPosts;
        prevYtSubscribers[profileId] = ytSubscribers;
        prevYtVideos[profileId] = ytVideos;
    }

    function distributePayments(uint256[] calldata profileIds, uint256[] calldata prices) external override onlyOwner {
        uint256 totalPaid = 0;
        for (uint256 i = 0; i < profileIds.length; i++) {
            address token = factory.profileIdToToken(profileIds[i]);
            uint256 supply = IERC20(token).totalSupply();
            uint256 payment = prices[i].mulDiv(supply, 1e18);
            totalPaid += payment;
            payable(Ownable(token).owner()).transfer(payment);
        }
        require(totalPaid <= treasuryGHO, "Insufficient Treasury");
        treasuryGHO -= totalPaid;
    }
}