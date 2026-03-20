// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WeatherOracle {

    address public owner;
    uint public rainfall;
    uint public threshold;

    mapping(address => uint) public insuredAmount;
    mapping(address => bool) public hasClaimed;

    constructor(uint _threshold) {
        owner = msg.sender;
        threshold = _threshold;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setRainfall(uint _rainfall) public onlyOwner {
        rainfall = _rainfall;
    }

    function insure() public payable {
        require(msg.value > 0);
        insuredAmount[msg.sender] += msg.value;
    }

    function claim() public {
        require(rainfall < threshold);
        require(!hasClaimed[msg.sender]);
        require(insuredAmount[msg.sender] > 0);

        hasClaimed[msg.sender] = true;

        uint payout = insuredAmount[msg.sender];
        insuredAmount[msg.sender] = 0;

        payable(msg.sender).transfer(payout);
    }

    function fundContract() public payable {}
}