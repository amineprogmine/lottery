// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
error Lottery__SendEnoughEth();

contract Lottery is VRFConsumerBaseV2 {
    uint256 private immutable i_entranceFee;
    address payable[] private s_Players;
    event raffleEnter(address indexed player);

    constructor(address vrfCoordinatorV2, uint256 entranceFee) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) {
            revert Lottery__SendEnoughEth();
        }
        s_Players.push(payable(msg.sender));
        emit raffleEnter(msg.sender);
    }

    function requestRandomWiner() external {}

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {}

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_Players[index];
    }
}
