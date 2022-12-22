// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

error Lottery__SendEnoughEth();

contract Lottery {
    uint256 private immutable i_entranceFee;
    address payable[] private s_Players;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function buyTicket() public payable {
        if (msg.value < i_entranceFee) {
            revert Lottery__SendEnoughEth();
        }
        s_Players.push(payable(msg.sender));
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_Players[index];
    }
}
