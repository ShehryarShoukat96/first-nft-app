// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Inspired by:
// https://www.myhsts.org/blog/ethereum-dapp-with-evm-remix-golang-truffle-and-solidity-part1.html
// https://betterprogramming.pub/how-to-create-nfts-with-solidity-4fa1398eb70a
contract Auction is ERC721 {
    using SafeMath for uint256;

    event NftCreated(uint indexed tokenId);
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

    uint256 public tokenId;
    address[] bidders;
    mapping(address => uint) public bids;
    AuctionState public STATE;

    constructor (
        uint _biddingTime,
        address _owner,
        uint _tokenId,
        string memory _tokenURI,
        string memory _tokenName,
        string memory _tokenSymbol
    ) ERC721 (_tokenName, _tokenSymbol) {
        auctionOwner = _owner;
        auctionStart = block.timestamp;
        auctionEnd = auctionStart.add(_biddingTime.mul(auctionTime));
        STATE = AuctionState.STARTED;
        tokenId = _tokenId;

        _safeMint(_owner, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);

        emit NftCreated(_tokenId);
    }

    modifier anOngoingAuction() {
        require(!_auctionEnded(), "Auction Ended");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == auctionOwner, "Only Auction owner can call this method");
        _;
    }

    function _auctionEnded () private returns (bool) {
        return (STATE == AuctionState.CANCELLED) || (block.timestamp > auctionEnd);
    }

    function getBid(address _address) public view returns (uint) {
        return bids[_address];
    }

    function transferNft() public onlyOwner returns (bool) {
        require(_auctionEnded(), "can't transfer, Auction is still  open");

        uint amount = bids[highestBidder];
        bids[highestBidder] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");

        require(sent, "Transfer failed");

        safeTransferFrom(msg.sender, highestBidder, tokenId);
        auctionOwner = highestBidder;

        return true;
    }

    function bid() public payable anOngoingAuction returns (bool) {
        uint newBid = bids[msg.sender].add(msg.value);
        require(newBid >= 10000, "bid should be at least 10000 Wei");
        require(newBid >  highestBid, "can/'t bid, Make a higher Bid");

        highestBidder = msg.sender;
        highestBid =  newBid;
        bidders.push(msg.sender);

        bids[msg.sender] = newBid;
        emit  BidEvent(highestBidder, highestBid);

        return true;
    }

    function withdraw() public returns (bool) {
        require(_auctionEnded(), "can't withdraw, Auction is still  open");
        require(highestBidder != msg.sender, "Highest Bidder is not allowed withdraw");

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
