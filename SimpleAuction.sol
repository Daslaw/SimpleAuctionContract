//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract SimpleAuction {
    //Declaring a global variable
    address payable public beneficiary; //address of the seller
    uint256 public auctionStopTime; // end time for the contract

    address public highestBidder; //Address of the bidder
    uint256 public highestBid; // The value of the highest bid

    mapping(address => uint256) public pendingReturns; // mapping to keep tractk of the bidder
    bool stopped = false;

    event HighestBidIncrease(address bidder, uint256 amount); // event called when a person bids
    event AuctionStopped(address winner, uint256 amount); // event called when the winner is gotten

    //This is a construction called once, it will declare the time for the auction, and the address of the beneficiary
    constructor(uint256 _biddingTime, address payable _beneficiary) {
        beneficiary = _beneficiary;
        // this is the timer for the auction
        auctionStopTime = block.timestamp + _biddingTime;
    }

    // The function called to place a bid
    function bid() public payable {
        if (block.timestamp > auctionStopTime) {
            revert("The auction has stopped");
        }

        if (msg.value <= highestBid) {
            revert("There is a higher/equal bid");
        }

        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncrease(msg.sender, msg.value);
    }

    //function to withdraw money
    function withdraw() public returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    //function to stop the auction
    function auctionStop() public {
        if (block.timestamp < auctionStopTime) {
            revert("The auction has not stopped yet");
        }

        if (stopped) {
            revert("The function auctionStopped has been called");
        }

        stopped = true;
        emit AuctionStopped(highestBidder, highestBid);

        beneficiary.transfer(highestBid);
    }
}
