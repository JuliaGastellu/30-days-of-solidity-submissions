// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubscriptionLogic {

    mapping(address => uint) public subscriptionExpiry;

    function subscribe(uint duration) public {
        subscriptionExpiry[msg.sender] = block.timestamp + duration;
    }

    function extend(uint duration) public {
        subscriptionExpiry[msg.sender] += duration;
    }

    function isActive(address user) public view returns(bool) {
        return subscriptionExpiry[user] > block.timestamp;
    }
}