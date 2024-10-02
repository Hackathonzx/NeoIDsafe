require("@nomicfoundation/hardhat-ethers");
require('@nomicfoundation/hardhat-toolbox');
require("dotenv").config();

async function deployContract(contractName, ...args) {
  const Contract = await hre.ethers.getContractFactory(contractName);

  // Get the current fee data
  const feeData = await hre.ethers.provider.getFeeData();

//   // Calculate gas settings that are likely to be accepted
//   const maxFeePerGas = feeData.maxFeePerGas ? feeData.maxFeePerGas.mul(2) : null; // Double the suggested max fee
//   const maxPriorityFeePerGas = feeData.maxPriorityFeePerGas ? feeData.maxPriorityFeePerGas.mul(2) : null; // Double the suggested priority fee

 // Calculate gas settings that are likely to be accepted
 const maxFeePerGas = feeData.maxFeePerGas * BigInt(2); // Double the suggested max fee
 const maxPriorityFeePerGas = feeData.maxPriorityFeePerGas * BigInt(2); // Double the suggested priority fee

  // Deploy the contract with the calculated gas settings
  const contract = await Contract.deploy(...args, {
    maxFeePerGas,
    maxPriorityFeePerGas,
  });

  await contract.waitForDeployment();
  console.log(`${contractName} deployed to:`, await contract.getAddress());
  return contract;
}

async function main() {
  // Deploy DIDRegistry contract
  const didRegistry = await deployContract("DIDRegistry");

  // Deploy CredentialNFT contract
  const credentialNFT = await deployContract("CredentialNFT");

  // Deploy VerificationOracle contract
  const ccipRouter = process.env.CCIP_ROUTER_ADDRESS; // Ensure this is set in your .env file
  const linkToken = process.env.LINK_TOKEN_ADDRESS; // Ensure this is set in your .env file
  const verificationOracle = await deployContract("VerificationOracle", ccipRouter, linkToken);
}

// Execute the main function
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
