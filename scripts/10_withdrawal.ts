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

  const nftContractBalance1 = await ethers.provider.getBalance(nusicAccessNFT.address);
  console.log("NusicAccessNFT Contract Balance Before withdraw = ",nftContractBalance1.toString());

  const ownerBalance1 = await ethers.provider.getBalance(owner.address);
  console.log("Owner Balance Before withdraw = ",ownerBalance1.toString());

  const treasuryBalance1 = await ethers.provider.getBalance(await nusicAccessNFT.treasuryAddress());
  console.log("Treasury Balance Before withdraw = ",treasuryBalance1.toString());

  const txt = await nusicAccessNFT.withdraw()
  console.log("nusicAccessNFT.withdraw txt.hash = ",txt.hash);
  const txtReceipt = await txt.wait();
  //console.log("txtReceipt = ",txtReceipt);
  
  const nftContractBalance2 = await ethers.provider.getBalance(nusicAccessNFT.address);
  console.log("NusicAccessNFT Contract Balance After withdraw = ",nftContractBalance2.toString());

  const ownerBalance2 = await ethers.provider.getBalance(owner.address);
  console.log("Owner Balance After withdraw = ",ownerBalance2.toString());

  const treasuryBalance2 = await ethers.provider.getBalance(await nusicAccessNFT.treasuryAddress());
  console.log("Treasury Balance After withdraw = ",treasuryBalance2.toString());

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
