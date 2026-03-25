// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LendingPool {
    mapping(address => uint) public deposits;
    mapping(address => uint) public collateral;
    mapping(address => uint) public borrowed;
    uint public interestRate = 10;

    function deposit() public payable {
        require(msg.value > 0, "Send ETH");
        deposits[msg.sender] += msg.value;
    }

    function depositCollateral() public payable {
        require(msg.value > 0, "Send collateral");
        collateral[msg.sender] += msg.value;
    }

    function borrow(uint amount) public {
        require(collateral[msg.sender] >= amount * 2, "Not enough collateral");
        require(address(this).balance >= amount, "Pool has no liquidity");

        borrowed[msg.sender] += amount;
        payable(msg.sender).transfer(amount);
    }

    function calculateInterest(address user) public view returns (uint) {
        return (borrowed[user] * interestRate) / 100;
    }

    function repay() public payable {
        require(borrowed[msg.sender] > 0, "No active loan");

        uint totalDebt = borrowed[msg.sender] + calculateInterest(msg.sender);
        require(msg.value >= totalDebt, "Not enough ETH to repay");

        borrowed[msg.sender] = 0;
    }

    function withdrawDeposit(uint amount) public {
        require(deposits[msg.sender] >= amount, "Insufficient deposit");

        deposits[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function withdrawCollateral() public {
        require(borrowed[msg.sender] == 0, "Outstanding loan");

        uint amount = collateral[msg.sender];
        require(amount > 0, "No collateral");

        collateral[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function getPoolBalance() public view returns (uint) {
        return address(this).balance;
    }
}