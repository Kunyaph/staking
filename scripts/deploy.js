const hre = require("hardhat");

async function main() {
  const accounts = await ethers.getSigners();
  // console.log(accounts);
  const account = accounts[1];
  console.log(account);

  const USDTtoken = await hre.ethers.getContractFactory("USDT");
  const kunyatoken = await hre.ethers.getContractFactory("Kunyastoken");
  const staking = await hre.ethers.getContractFactory("Staking");

  const USDTtoken = await USDTtoken.connect(account).deploy();
  await USDTtoken.deployed();
  console.log(`USDT contract was deployed to ${USDTtoken.address}`);

  const kunyatoken = await kunyatoken.connect(account).deploy();
  await kunyatoken.deployed();
  console.log(`Kunya token contract was deployed to ${kunyatoken.address}`);

  const staking = await staking.connect(account).deploy(kunyastoken.address, USDTtoken.address);
  await staking.deployed();
  console.log(`Staking contract was deployed to ${staking.address}`);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
