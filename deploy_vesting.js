const hre = require("hardhat");

async function main() {
  const TOKEN_ADDRESS = "0x..."; // Target ERC20 address
  const Vesting = await hre.ethers.getContractFactory("TokenVesting");
  const vesting = await Vesting.deploy(TOKEN_ADDRESS);

  await vesting.waitForDeployment();
  console.log(`Vesting Vault deployed to: ${await vesting.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
