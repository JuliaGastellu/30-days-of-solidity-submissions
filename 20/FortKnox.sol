// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FortKnox {

    mapping(address => uint) public balances;
    bool private locked;

    modifier nonReentrant() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    function deposit() public payable {
        require(msg.value > 0);
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint amount) public nonReentrant {
        require(balances[msg.sender] >= amount);

        balances[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success);
    }

    function getVaultBalance() public view returns(uint) {
        return address(this).balance;
    }
}