// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
error Lottery__SendEnoughEth();
error Lottery__transfertFailed();

contract Lottery is VRFConsumerBaseV2 {
    uint256 private immutable i_entranceFee;
    address payable[] private s_Players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callBackGasLimit;
    uint16 private constant REQUEST_CONFIMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    address private s_recentWinner;

    event raffleEnter(address indexed player);
    event requestedRaffleWinner(uint256 indexed requestId);
    event winnerPicked(address winner);

    constructor(
        address vrfCoordinatorV2,
        uint256 entranceFee,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callBackGasLimit = callbackGasLimit;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) {
            revert Lottery__SendEnoughEth();
        }
        s_Players.push(payable(msg.sender));
        emit raffleEnter(msg.sender);
    }

    function requestRandomWinner() external {
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIMATIONS,
            i_callBackGasLimit,
            NUM_WORDS
        );

        emit requestedRaffleWinner(requestId);
    }

    function fulfillRandomWords(
        uint256 /* requestId */,
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_Players.length;
        address payable recentWinner = s_Players[indexOfWinner];
        s_recentWinner = recentWinner;
        (bool success, ) = s_recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Lottery__transfertFailed();
        }
        emit winnerPicked(s_recentWinner);
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_Players[index];
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }
}
