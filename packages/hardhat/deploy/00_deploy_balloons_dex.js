// deploy/00_deploy_balloons_dex.js

const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log(deployer);
  await deploy("Balloons", {
    from: deployer,
    log: true,
  });

  const balloons = await ethers.getContract("Balloons", deployer);

  await deploy("DEX", {
    from: deployer,
    args: [balloons.address],
    log: true,
  });

  const dex = await ethers.getContract("DEX", deployer);

  // paste in your address here to get 10 balloons on deploy:
  await balloons.transfer(
    "0x1579E9e84Db615EBD49E0825a727c056eb0d030F",
    "" + 10 * 10 ** 18
  );

  // uncomment to init DEX on deploy:
  console.log(
    "Approving DEX (" + dex.address + ") to take Balloons from main account..."
  );
  // If you are going to the testnet make sure your deployer account has enough ETH
  let output = await balloons.approve(
    dex.address,
    ethers.utils.parseEther("100")
  );
  console.log(output);
  console.log("INIT exchange...");
  let output1 = await dex.init("" + 3 * 10 ** 18, {
    value: ethers.utils.parseEther("3"),
    gasLimit: 200000,
  });
  console.log(output1);
};
module.exports.tags = ["Balloons", "DEX"];
