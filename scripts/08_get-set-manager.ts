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

  const txt = await nusicAccessNFT.setManager("0x07C920eA4A1aa50c8bE40c910d7c4981D135272B");
  console.log("nusicAccessNFT.setManager txt.hash = ",txt.hash);
  const txtReceipt = await txt.wait();
  //console.log("txtReceipt = ",txtReceipt); 

  const managerAddress = await nusicAccessNFT.managerAddress();
  console.log("nusicAccessNFT.managerAddress txt.hash = ",managerAddress);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
