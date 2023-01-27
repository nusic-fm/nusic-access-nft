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

  const tokenURI1 = await nusicAccessNFT.tokenURI(1);
  console.log("tokenURI1 1 txt.hash = ",tokenURI1);
  const tokenURI2 = await nusicAccessNFT.tokenURI(2);
  console.log("tokenURI2 2 txt.hash = ",tokenURI2);
  const tokenURI3 = await nusicAccessNFT.tokenURI(16);
  console.log("tokenURI3 16 txt.hash = ",tokenURI3);
  const tokenURI4 = await nusicAccessNFT.tokenURI(17);
  console.log("tokenURI4 17 txt.hash = ",tokenURI4);
  const tokenURI5 = await nusicAccessNFT.tokenURI(56);
  console.log("tokenURI5 56 txt.hash = ",tokenURI5);
  const tokenURI6 = await nusicAccessNFT.tokenURI(57);
  console.log("tokenURI6 57 txt.hash = ",tokenURI6);
  


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
