// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Stablecoin {
    string public name = "MyStablecoin";
    string public symbol = "MSC";
    uint8 public decimals = 18;
    uint public totalSupply;

    mapping(address => uint) public balanceOf;
    mapping(address => uint) public collateral;
    uint public collateralRatio = 150;
    uint public pegPrice = 1 ether;
    address public owner;

    event Transfer(address indexed from, address indexed to, uint value);
    event Mint(address indexed user, uint stableAmount, uint collateralAmount);
    event Burn(address indexed user, uint stableAmount, uint collateralReturned);

    constructor() {
        owner = msg.sender;
    }

    function depositCollateral() public payable {
        require(msg.value > 0, "Send ETH");
        collateral[msg.sender] += msg.value;
    }

    function mint(uint amount) public {
        require(amount > 0, "Invalid amount");

        uint requiredCollateral = (amount * collateralRatio) / 100;
        require(collateral[msg.sender] >= requiredCollateral, "Not enough collateral");

        balanceOf[msg.sender] += amount;
        totalSupply += amount;

        emit Mint(msg.sender, amount, requiredCollateral);
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) public {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        require(amount > 0, "Invalid amount");

        uint collateralToReturn = (amount * collateralRatio) / 100;
        require(address(this).balance >= collateralToReturn, "Insufficient collateral in contract");

        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        collateral[msg.sender] -= collateralToReturn;

        payable(msg.sender).transfer(collateralToReturn);

        emit Burn(msg.sender, amount, collateralToReturn);
        emit Transfer(msg.sender, address(0), amount);
    }

    function transfer(address to, uint amount) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function getRequiredCollateral(uint amount) public view returns (uint) {
        return (amount * collateralRatio) / 100;
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}