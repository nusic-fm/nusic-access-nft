import { ethers } from 'hardhat';
import { NusicAccessNFT, NusicAccessNFT__factory } from '../typechain';
const addresses = require("./address.json");
/*
* Main deployment script to deploy all the relevent contracts
*/
async function main() {
  const [owner, addr1] = await ethers.getSigners();

  const NusicAccessNFT:NusicAccessNFT__factory =  await ethers.getContractFactory("NusicAccessNFT");
  
  // Using address for localhost
  //const nusicAccessNFT:NusicAccessNFT = await NusicAccessNFT.deploy("NUSIC Access NFT", "NUA");
  const nusicAccessNFT:NusicAccessNFT = await NusicAccessNFT.deploy("Access Demo", "ACD");

  await nusicAccessNFT.deployed(); 
  console.log("NusicAccessNFT deployed to:", nusicAccessNFT.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
