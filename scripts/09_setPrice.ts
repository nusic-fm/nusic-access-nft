import { BigNumber } from 'ethers';
import { ethers } from 'hardhat';
import { NusicAccessNFT, NusicAccessNFT__factory } from '../typechain';
const addresses = require("./address.json");
/*
* Main deployment script to deploy all the relevent contracts
*/
async function main() {
  const [owner, addr1] = await ethers.getSigners();

  const network = addresses.localhost;
  
  const NusicAccessNFT:NusicAccessNFT__factory =  await ethers.getContractFactory("NusicAccessNFT");
  const nusicAccessNFT:NusicAccessNFT = await NusicAccessNFT.attach(network.nusicAccessNFT);
  console.log("NusicAccessNFT Address:", nusicAccessNFT.address);


  const txt1 = await nusicAccessNFT.setMinimumPlatinumTokenPrice(ethers.utils.parseEther("3"));
  console.log("nusicAccessNFT.setPrice txt1.hash = ",txt1.hash);
  const txtReceipt1 = await txt1.wait();

  const txt2 = await nusicAccessNFT.setGoldTokenPrice(ethers.utils.parseEther("2"));
  console.log("nusicAccessNFT.setPrice txt2.hash = ",txt2.hash);
  const txtReceipt2 = await txt2.wait();
  //console.log("txtReceipt = ",txtReceipt); 

  const txt3 = await nusicAccessNFT.setVipTokenPrice(ethers.utils.parseEther("1"));
  console.log("nusicAccessNFT.setPrice txt3.hash = ",txt3.hash);
  const txtReceipt3 = await txt3.wait();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
