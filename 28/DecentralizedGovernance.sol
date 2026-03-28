// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedGovernance {
    struct Proposal {
        string description;
        uint voteCount;
        bool executed;
    }

    mapping(address => uint) public votingPower;
    mapping(uint => mapping(address => bool)) public hasVoted;
    Proposal[] public proposals;
    address public owner;

    constructor() {
        owner = msg.sender;
        votingPower[msg.sender] = 100;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function grantVotingPower(address user, uint amount) public onlyOwner {
        votingPower[user] += amount;
    }

    function createProposal(string calldata description) public {
        require(votingPower[msg.sender] > 0, "No voting power");
        proposals.push(Proposal(description, 0, false));
    }

    function vote(uint proposalId) public {
        require(proposalId < proposals.length, "Invalid proposal");
        require(votingPower[msg.sender] > 0, "No voting power");
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        require(!proposals[proposalId].executed, "Proposal executed");

        proposals[proposalId].voteCount += votingPower[msg.sender];
        hasVoted[proposalId][msg.sender] = true;
    }

    function executeProposal(uint proposalId) public onlyOwner {
        require(proposalId < proposals.length, "Invalid proposal");
        require(!proposals[proposalId].executed, "Already executed");
        require(proposals[proposalId].voteCount > 0, "No votes");

        proposals[proposalId].executed = true;
    }

    function getProposal(uint proposalId) public view returns (string memory, uint, bool) {
        Proposal memory proposal = proposals[proposalId];
        return (proposal.description, proposal.voteCount, proposal.executed);
    }

    function getProposalCount() public view returns (uint) {
        return proposals.length;
    }
}