require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  etherscan: {
    apiKey: process.env.etherscan_api,
  },
  networks: {
    bnbtestnet: {
      url: 'https://data-seed-prebsc-2-s3.binance.org:8545',
      chainId: 97,
      accounts: {
        mnemonic: process.env.mnemonic,
      },
    },
    },
  }