// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract YieldFarming {
    mapping(address => uint) public stakedBalance;
    mapping(address => uint) public rewardBalance;
    mapping(address => uint) public lastUpdate;

    uint public rewardRate = 1;

    function stake() public payable {
        require(msg.value > 0, "Send ETH to stake");

        if (stakedBalance[msg.sender] > 0) {
            rewardBalance[msg.sender] += calculateRewards(msg.sender);
        }

        stakedBalance[msg.sender] += msg.value;
        lastUpdate[msg.sender] = block.timestamp;
    }

    function unstake(uint amount) public {
        require(stakedBalance[msg.sender] >= amount, "Not enough staked");

        rewardBalance[msg.sender] += calculateRewards(msg.sender);
        stakedBalance[msg.sender] -= amount;
        lastUpdate[msg.sender] = block.timestamp;

        payable(msg.sender).transfer(amount);
    }

    function claimRewards() public {
        uint rewards = rewardBalance[msg.sender] + calculateRewards(msg.sender);
        require(rewards > 0, "No rewards");

        rewardBalance[msg.sender] = 0;
        lastUpdate[msg.sender] = block.timestamp;

        payable(msg.sender).transfer(rewards);
    }

    function calculateRewards(address user) public view returns (uint) {
        if (stakedBalance[user] == 0) {
            return 0;
        }

        uint stakingTime = block.timestamp - lastUpdate[user];
        return (stakedBalance[user] * stakingTime * rewardRate) / 1 days / 100;
    }

    function fundRewards() public payable {}

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}