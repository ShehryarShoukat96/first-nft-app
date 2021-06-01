const SimpleStorage = artifacts.require("./SimpleStorage.sol");
const Auction = artifacts.require("./Auction.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(Auction, "10", accounts[0], "SKB", "GPU");
};
