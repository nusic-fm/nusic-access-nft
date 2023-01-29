import { BigNumber } from 'ethers';
import { ethers } from 'hardhat';
import { NusicAccessNFT, NusicAccessNFT__factory } from '../typechain';
const addresses = require("./address.json");
/*
* Main deployment script to deploy all the relevent contracts
*/
async function main() {
  const [owner, addr1, addr2] = await ethers.getSigners();

  const network = addresses.localhost;
  
  const NusicAccessNFT:NusicAccessNFT__factory =  await ethers.getContractFactory("NusicAccessNFT");
  const nusicAccessNFT:NusicAccessNFT = await NusicAccessNFT.attach(network.nusicAccessNFT);
  console.log("NusicAccessNFT Address:", nusicAccessNFT.address);

  const txt = await nusicAccessNFT.setTreasury(addr1.address);
  console.log("nusicAccessNFT.setTreasury txt.hash = ",txt.hash);
  const txtReceipt = await txt.wait();
  //console.log("txtReceipt = ",txtReceipt); 

  const treasuryAddress = await nusicAccessNFT.treasuryAddress();
  console.log("nusicAccessNFT.treasuryAddress txt.hash = ",treasuryAddress);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
