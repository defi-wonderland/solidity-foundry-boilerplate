// SPDX-License-License: MIT
pragma solidity ^0.8.20;

import "../interfaces/IOracle.sol";

contract MockOracle is IOracle {
    mapping(uint256 => uint256) public igFollowers;
    mapping(uint256 => uint256) public igPosts;
    mapping(uint256 => uint256) public ytSubscribers;
    mapping(uint256 => uint256) public ytVideos;

    function setMetrics(
        uint256 profileId,
        uint256 _igFollowers,
        uint256 _igPosts,
        uint256 _ytSubscribers,
        uint256 _ytVideos
    ) external {
        igFollowers[profileId] = _igFollowers;
        igPosts[profileId] = _igPosts;
        ytSubscribers[profileId] = _ytSubscribers;
        ytVideos[profileId] = _ytVideos;
    }

    function getMetrics(uint256 profileId) external override view returns (
        uint256,
        uint256,
        uint256,
        uint256
    ) {
        return (
            igFollowers[profileId],
            igPosts[profileId],
            ytSubscribers[profileId],
            ytVideos[profileId]
        );
    }
}