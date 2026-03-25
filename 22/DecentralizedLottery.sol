// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract DecentralizedLottery is VRFConsumerBaseV2Plus {
    address public owner;
    address[] public players;
    address public recentWinner;
    uint256 public entryFee;
    uint256 public lastRequestId;
    uint256 public subscriptionId;
    bytes32 public keyHash;
    uint32 public callbackGasLimit = 200000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;

    enum LotteryState {
        OPEN,
        CLOSED,
        CALCULATING
    }

    LotteryState public lotteryState;

    constructor(
        address _vrfCoordinator,
        uint256 _subscriptionId,
        bytes32 _keyHash,
        uint256 _entryFee
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        owner = msg.sender;
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LotteryState.CLOSED;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function startLottery() public onlyOwner {
        require(lotteryState == LotteryState.CLOSED, "Lottery already open");
        lotteryState = LotteryState.OPEN;
    }

    function enter() public payable {
        require(lotteryState == LotteryState.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH");
        players.push(msg.sender);
    }

    function endLottery() public onlyOwner {
        require(lotteryState == LotteryState.OPEN, "Lottery not open");
        require(players.length > 0, "No players");

        lotteryState = LotteryState.CALCULATING;

        lastRequestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
    }

    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        uint256 winnerIndex = randomWords[0] % players.length;
        address winner = players[winnerIndex];

        recentWinner = winner;
        lotteryState = LotteryState.CLOSED;
        players = new address;

        (bool success, ) = payable(winner).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    function getPlayersCount() public view returns (uint256) {
        return players.length;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}