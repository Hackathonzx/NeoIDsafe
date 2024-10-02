require("@nomicfoundation/hardhat-ethers");
require('@nomicfoundation/hardhat-toolbox');
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY; // Correctly accessing the PRIVATE_KEY

module.exports = {
  solidity: "0.8.24",
  networks: {
    neoXTestnet: { // Remove the extra 'networks' key
      chainId: 12227332,
      url: "https://neoxt4seed1.ngd.network",
      accounts: [PRIVATE_KEY], // Use the PRIVATE_KEY variable
      gasPrice: "auto",
      gasMultiplier: 2,
    }
  },
};
