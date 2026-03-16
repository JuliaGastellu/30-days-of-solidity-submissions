// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasSaver {

    struct Proposal {
        string name;
        uint voteCount;
    }

    Proposal[] public proposals;

    mapping(address => bool) public hasVoted;

    constructor(string[] memory proposalNames) {
        uint length = proposalNames.length;
        for (uint i = 0; i < length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    function vote(uint proposalIndex) external {
        require(!hasVoted[msg.sender]);

        hasVoted[msg.sender] = true;

        proposals[proposalIndex].voteCount += 1;
    }

    function getProposal(uint index) external view returns(string memory, uint) {
        Proposal storage p = proposals[index];
        return (p.name, p.voteCount);
    }

    function proposalCount() external view returns(uint) {
        return proposals.length;
    }
}