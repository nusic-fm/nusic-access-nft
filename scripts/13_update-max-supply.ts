import { BigNumber } from 'ethers';
import { ethers } from 'hardhat';
import { LittleHaitiNFT, LittleHaitiNFT__factory } from '../typechain';
const addresses = require("./address.json");
/*
* Main deployment script to deploy all the relevent contracts
*/
async function main() {
  const [owner, addr1] = await ethers.getSigners();

  const network = addresses.localhost;
  
  const LittleHaitiNFT:LittleHaitiNFT__factory =  await ethers.getContractFactory("LittleHaitiNFT");
  const littleHaitiNFT:LittleHaitiNFT = await LittleHaitiNFT.attach(network.littleHaitiNFT);
  console.log("LittleHaitiNFT Address:", littleHaitiNFT.address);

  const txt = await littleHaitiNFT.updateMaxSupply(20);
  console.log("littleHaitiNFT.updateMaxSupply txt.hash = ",txt.hash);
  const txtReceipt = await txt.wait();
  //console.log("txtReceipt = ",txtReceipt); 

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
