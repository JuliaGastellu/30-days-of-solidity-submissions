// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleNFT {
    string public name = "SimpleNFT";
    string public symbol = "SNFT";

    mapping(uint => address) public ownerOf;
    mapping(address => uint) public balanceOf;
    mapping(uint => string) public tokenURI;

    uint public totalSupply;

    event Transfer(address indexed from, address indexed to, uint indexed tokenId);

    function mint(string memory _tokenURI) public {
        uint tokenId = totalSupply + 1;

        ownerOf[tokenId] = msg.sender;
        balanceOf[msg.sender] += 1;
        tokenURI[tokenId] = _tokenURI;
        totalSupply = tokenId;

        emit Transfer(address(0), msg.sender, tokenId);
    }

    function transferFrom(address from, address to, uint tokenId) public {
        require(ownerOf[tokenId] == from, "Not owner");
        require(msg.sender == from, "Not authorized");
        require(to != address(0), "Invalid recipient");

        ownerOf[tokenId] = to;
        balanceOf[from] -= 1;
        balanceOf[to] += 1;

        emit Transfer(from, to, tokenId);
    }
}