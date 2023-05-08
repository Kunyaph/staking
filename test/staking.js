const { expect } = require("chai");

describe("StakingContract", function () {
  let USDT;
  let kunyasoken;
  let staking;
  let owner;
  let user;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    const USDTToken = await ethers.getContractFactory("USDT");
    usdtToken = await USDTToken.deploy();
    await usdtToken.deployed();

    const YourToken = await ethers.getContractFactory("YourToken");
    yourToken = await YourToken.deploy();
    await yourToken.deployed();

    const StakingContract = await ethers.getContractFactory("StakingContract");
    stakingContract = await StakingContract.deploy(usdtToken.address, yourToken.address);
    await stakingContract.deployed();

    // Mint some initial USDT tokens for testing
    await usdtToken.connect(owner).mint(user.address, ethers.utils.parseEther("1000"));
  });

  it("should allow user to buy tokens, stake, and claim rewards", async function () {
    // Buy tokens with USDT and stake
    await usdtToken.connect(user).approve(stakingContract.address, ethers.utils.parseEther("100"));
    await stakingContract.connect(user).buyToken(ethers.utils.parseEther("100"));

    // Check staked balance
    const stakedBalance = await stakingContract.stakedBalance(user.address);
    expect(stakedBalance).to.equal(ethers.utils.parseEther("100"));

    // Claim rewards
    await stakingContract.connect(user).claim();

    // Check claimed rewards
    const yourTokenBalance = await yourToken.balanceOf(user.address);
    expect(yourTokenBalance).to.be.above(0);
  });

  it("should allow user to withdraw staked tokens", async function () {
    // Buy tokens with USDT and stake
    await usdtToken.connect(user).approve(stakingContract.address, ethers.utils.parseEther("100"));
    await stakingContract.connect(user).buyToken(ethers.utils.parseEther("100"));

    // Withdraw staked tokens
    await stakingContract.connect(user).withdraw();

    // Check staked balance
    const stakedBalance = await stakingContract.stakedBalance(user.address);
    expect(stakedBalance).to.equal(0);
  });

  it("should allow owner to perform token airdrop to whitelisted addresses", async function () {
    // Add user to whitelist
    await stakingContract.addToWhitelist(user.address);

    // Perform token airdrop
    await stakingContract.connect(owner).airdropTokens([user.address], ethers.utils.parseEther("200"));

    // Check token balance after airdrop
    const yourTokenBalance = await yourToken.balanceOf(user.address);
    expect(yourTokenBalance).to.equal(ethers.utils.parseEther("200"));
  });
});