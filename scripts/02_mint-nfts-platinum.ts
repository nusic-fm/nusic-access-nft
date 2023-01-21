import { BigNumber } from 'ethers';
import { ethers } from 'hardhat';
import { NusicAccessNFT, NusicAccessNFT__factory } from '../typechain';
const addresses = require("./address.json");
/*
* Main deployment script to deploy all the relevent contracts
*/
async function main() {
  const [owner, addr1, addr2, addr3] = await ethers.getSigners();

  const network = addresses.localhost;
  
  const NusicAccessNFT:NusicAccessNFT__factory =  await ethers.getContractFactory("NusicAccessNFT");
  const nusicAccessNFT:NusicAccessNFT = await NusicAccessNFT.attach(network.nusicAccessNFT);
  console.log("NusicAccessNFT Address:", nusicAccessNFT.address);


  const numberOfTokens = 1
  const tokenPrice = (ethers.utils.parseEther("5")).mul(numberOfTokens);
  const txt = await nusicAccessNFT.connect(owner).platinumTokenCrossMint(owner.address,numberOfTokens, {value: tokenPrice});
  const txt1 = await nusicAccessNFT.connect(owner).platinumTokenNativeMint(owner.address,numberOfTokens, {value: tokenPrice});
  console.log("nusicAccessNFT.platinumTokenMint txt.hash = ",txt.hash);
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
