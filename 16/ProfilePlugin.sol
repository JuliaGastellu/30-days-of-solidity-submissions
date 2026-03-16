// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProfilePlugin {

    mapping(address => uint) public achievements;

    function addAchievement(address player) external {
        achievements[player] += 1;
    }

    function getAchievements(address player) external view returns(uint) {
        return achievements[player];
    }
}