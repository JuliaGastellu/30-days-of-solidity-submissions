// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SignThis {

    address public signer;
    mapping(address => bool) public hasEntered;

    constructor(address _signer) {
        signer = _signer;
    }

    function enter(bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) public {
        require(!hasEntered[msg.sender]);

        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        address recovered = ecrecover(ethSignedMessageHash, v, r, s);

        require(recovered == signer);

        hasEntered[msg.sender] = true;
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
        );
    }
}