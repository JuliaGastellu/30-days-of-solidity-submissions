// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISimpleNFT {
    function ownerOf(uint tokenId) external view returns (address);
    function transferFrom(address from, address to, uint tokenId) external;
}

contract NFTMarketplace {
    struct Listing {
        address seller;
        uint price;
        bool active;
    }

    ISimpleNFT public nft;
    address public owner;
    uint public royaltyPercent;

    mapping(uint => Listing) public listings;

    constructor(address _nftAddress, uint _royaltyPercent) {
        nft = ISimpleNFT(_nftAddress);
        owner = msg.sender;
        royaltyPercent = _royaltyPercent;
    }

    function listNFT(uint tokenId, uint price) public {
        require(nft.ownerOf(tokenId) == msg.sender, "Not owner");
        require(price > 0, "Invalid price");

        listings[tokenId] = Listing(msg.sender, price, true);
    }

    function buyNFT(uint tokenId) public payable {
        Listing storage listing = listings[tokenId];

        require(listing.active, "Not listed");
        require(msg.value >= listing.price, "Not enough ETH");

        uint royalty = (listing.price * royaltyPercent) / 100;
        uint sellerAmount = listing.price - royalty;

        listing.active = false;

        payable(owner).transfer(royalty);
        payable(listing.seller).transfer(sellerAmount);

        nft.transferFrom(listing.seller, msg.sender, tokenId);
    }

    function cancelListing(uint tokenId) public {
        Listing storage listing = listings[tokenId];
        require(listing.seller == msg.sender, "Not seller");
        require(listing.active, "Not active");

        listing.active = false;
    }

    function getListing(uint tokenId) public view returns (address, uint, bool) {
        Listing memory listing = listings[tokenId];
        return (listing.seller, listing.price, listing.active);
    }
}