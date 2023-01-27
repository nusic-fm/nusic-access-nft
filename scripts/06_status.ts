import { BigNumber } from 'ethers';
import { ethers } from 'hardhat';
import { NusicAccessNFT, NusicAccessNFT__factory } from '../typechain';
const addresses = require("./address.json");
/*
* Main deployment script to deploy all the relevent contracts
*/
async function main() {
  const [owner, addr1, addr2] = await ethers.getSigners();

  const network = addresses.matic;
  
  const NusicAccessNFT:NusicAccessNFT__factory =  await ethers.getContractFactory("NusicAccessNFT");
  const nusicAccessNFT:NusicAccessNFT = await NusicAccessNFT.attach(network.nusicAccessNFT);
  console.log("NusicAccessNFT Address:", nusicAccessNFT.address);

  const totalSupply = await nusicAccessNFT.totalSupply();
  console.log("totalSupply = ",totalSupply.toString());
  
  const nftContractBalance = await ethers.provider.getBalance(nusicAccessNFT.address);
  console.log("NusicAccessNFT Contract Balance = ",nftContractBalance.toString());

  const ownerBalance = await ethers.provider.getBalance(owner.address);
  console.log("Owner Balance = ",ownerBalance.toString());

  const treasuryBalance = await ethers.provider.getBalance(await nusicAccessNFT.treasuryAddress());
  console.log("Treasury Balance = ",treasuryBalance.toString());

  const vipTokenCounter = await nusicAccessNFT.vipTokenCounter();
  console.log("vipTokenCounter Balance = ",vipTokenCounter.toString());

  const platinumTokenCounter = await nusicAccessNFT.platinumTokenCounter();
  console.log("platinumTokenCounter Balance = ",platinumTokenCounter.toString());

  const goldTokenCounter = await nusicAccessNFT.goldTokenCounter();
  console.log("goldTokenCounter Balance = ",goldTokenCounter.toString());

  console.log("minimumPlatinumTokenPrice = ",(await nusicAccessNFT.minimumPlatinumTokenPrice()).toString());
  console.log("goldTokenPrice = ",(await nusicAccessNFT.goldTokenPrice()).toString());
  console.log("vipTokenPrice = ",(await nusicAccessNFT.vipTokenPrice()).toString());


  /*
  const addr1Balance = await ethers.provider.getBalance(addr1.address);
  console.log("Addr 1 Balance = ",addr1Balance.toString());

  const addr2Balance = await ethers.provider.getBalance(addr2.address);
  console.log("Addr 2 Balance = ",addr2Balance.toString());
  */

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
