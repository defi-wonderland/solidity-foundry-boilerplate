// SPDX-License-License: MIT
pragma solidity ^0.8.20;

interface IOracle {
    function getMetrics(uint256 profileId) external view returns (
        uint256 igFollowers,
        uint256 igPosts,
        uint256 ytSubscribers,
        uint256 ytVideos
    );
}