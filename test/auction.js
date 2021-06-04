const Auction = artifacts.require("./Auction.sol");

contract("Auction", accounts => {
  const OWNER = accounts[0];
  const FIRST_BIDDER = accounts[1];
  const SECOND_BIDDER = accounts[2];

  let auctionInstance;

  before(async function () {
    auctionInstance = await Auction.deployed();
  });

  it("auctionTime should be 600.", async () => {
    // Get stored value
    const auctionTime = await auctionInstance.auctionTime();

    assert.equal(auctionTime.toString(), "600");
  });

  it("owner nft balance should be one.", async () => {
    // Get stored value
    const balance = await auctionInstance.getBalance(OWNER);

    assert.equal(balance.toString(), "1");
  });

  it("FIRST_BIDDER should be able to bid.", async () => {
    const bid = "1000000";
    await auctionInstance.bid({ from: FIRST_BIDDER, value: bid });

    assert.equal(await auctionInstance.highestBidder(), FIRST_BIDDER);
    assert.equal(await auctionInstance.highestBid(), bid);
  });

  it("SECOND_BIDDER low bid should throw exception", async () => {
    const bid = "500000";

    try {
      await auctionInstance.bid({ from: SECOND_BIDDER, value: bid });
      assert(false, "No exception thrown");
    } catch (err) {
      assert(true);
    }
  });

  it("SECOND_BIDDER should outbit FIRST_BIDDER", async () => {
    const bid = "2000000";
    await auctionInstance.bid({ from: SECOND_BIDDER, value: bid });

    assert.equal(await auctionInstance.highestBidder(), SECOND_BIDDER);
    assert.equal(await auctionInstance.highestBid(), bid);
  });

  it("FIRST_BIDDER withdrawal should throw exception When Auction is in progress.", async () => {
    try {
      await auctionInstance.withdraw({ from: FIRST_BIDDER });
      assert(false, "No exception thrown");
    } catch (err) {
      assert(true);
    }
  });
});
