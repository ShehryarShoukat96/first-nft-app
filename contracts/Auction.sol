// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

// Inspired by https://www.myhsts.org/blog/ethereum-dapp-with-evm-remix-golang-truffle-and-solidity-part1.html
contract Auction {
    event BidEvent(address indexed highestBidder, uint256 highestBid);
    event WithdrawalEvent(address withdrawer, uint256 amount);
    event CanceledEvent(string message, uint256 time);

    uint256 public constant auctionTime = 10 minutes;
    uint256 public auctionStart;
    uint256 public auctionEnd;
    uint256 public highestBid;
    address internal auctionOwner;
    address public highestBidder;

    enum AuctionState { STARTED, CANCELLED }

    struct Car {
        string Brand;
        string Rnumber;
    }

    Car public Mycar;
    address[] bidders;
    mapping(address => uint) public bids;
    AuctionState public STATE;

    constructor (uint _biddingTime, address  _owner,string memory _brand, string memory _Rnumber) {
        auctionOwner = _owner;
        auctionStart = block.timestamp;
        auctionEnd = auctionStart +  (_biddingTime * auctionTime);
        STATE = AuctionState.STARTED;

        Mycar = Car({
            Brand: _brand,
            Rnumber: _Rnumber
        });
    }

    modifier anOngoingAuction() {
        require(!_auctionEnded(), "Auction Ended");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == auctionOwner, "Only Auction owner can call this method");
        _;
    }

    function _auctionEnded () private pure returns (bool) {
        return (STATE == AuctionState.CANCELLED) || (block.timestamp <= auctionEnd);
    }

    function bid() public payable anOngoingAuction returns (bool) {
        require(bids[msg.sender] + msg.value >  highestBid, "can/'t bid, Make a higher Bid");

        highestBidder = msg.sender;
        highestBid =  (bids[msg.sender] + msg.value);
        bidders.push(msg.sender);

        bids[msg.sender] = bids[msg.sender] + msg.value;
        emit  BidEvent(highestBidder, highestBid);

        return true;
    }

    function  withdraw() public returns (bool) {
        require(block.timestamp > auctionEnd , "can't withdraw, Auction is still  open");
        uint amount = bids[msg.sender];
        bids[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");

        require(sent, "Withdraw failed");
        WithdrawalEvent(msg.sender,  amount);

        return true;
    }

    function cancel_auction() public onlyOwner  anOngoingAuction returns (bool) {
        STATE = AuctionState.CANCELLED;
        CanceledEvent("Auction Cancelled", block.timestamp);

        return true;
    }
}
