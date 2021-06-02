const SimpleStorage = artifacts.require("./SimpleStorage.sol");
const Auction = artifacts.require("./Auction.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(Auction,
    "10", // uint _biddingTime,
    accounts[0], // address _owner
    "1", // uint _tokenId
    "https://ipfs.io/ipfs/QmaSED9ZSbdGts5UZqueFJjrJ4oHH3GnmGJdSDrkzpYqRS?filename=the-chainlink-knight.json", // string _tokenURI
    "LOCO", // string _tokenName
    "LC" // string _tokenSymbol
  );
};
