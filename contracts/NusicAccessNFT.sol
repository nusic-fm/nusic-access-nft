// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "hardhat/console.sol";

contract NusicAccessNFT is Ownable, ERC721Pausable {
    using Address for address;
    using Strings for uint256;

    // URI to be used before Reveal
    string public defaultURI;
    string public baseURI;

    address public treasuryAddress;
    address public managerAddress;
    uint256 public tokenMinted;
    address public crossmintAddress;

    bool public publicSaleLive = true;

    uint256 public MAX_SUPPLY = 112171;
    uint256 public MINT_PER_TXT = 100; // Mint per Transaction
    uint256 public price = 199 ether;

    event Minted(address indexed to, uint256 tokenQuantity, uint256 amountTransfered, string _type);
    
    constructor() ERC721("NUSIC Access NFT", "NUA") {
        defaultURI = "https://bafkreigj4ynovugfqsewvfgche6ql5gozlox7p5cjfiw7uelfscfbk3keu.ipfs.nftstorage.link/";
        treasuryAddress = 0x7037a3B32A68d532318c94243ba3145435f7a300;
        crossmintAddress = 0x12A80DAEaf8E7D646c4adfc4B107A2f1414E2002;
    }
    
    modifier onlyOwnerOrManager() {
        require((owner() == msg.sender) || (managerAddress == msg.sender), "Caller needs to Owner or Manager");
        _;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory URI) public onlyOwnerOrManager {
		baseURI = URI;
	}

    function setDefaultRI(string memory _defaultURI) public onlyOwnerOrManager {
		defaultURI = _defaultURI;
	}

    function togglePublicSaleLive() public onlyOwnerOrManager {
        publicSaleLive = !publicSaleLive;
    }

    function setPrice(uint256 newPrice) public onlyOwnerOrManager {
        require(newPrice > 0, "Price can not be zero");
        price = newPrice;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Token does not exists");
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(),".json")) : defaultURI;
    }

    function setManager(address _manager) public onlyOwner{
        managerAddress = _manager;
    }

    function setTreasury(address _treasuryAddress) public onlyOwnerOrManager{
        treasuryAddress = _treasuryAddress;
    }


    function setCrossmintAddress(address _crossmintAddress) public onlyOwnerOrManager{
        crossmintAddress = _crossmintAddress;
    }

    function updateMaxSupply(uint256 _maxSupply) public onlyOwnerOrManager{
        MAX_SUPPLY = _maxSupply;
    }

    function updateMintPerTxt(uint256 _mintPerTxt) public onlyOwnerOrManager{
        MINT_PER_TXT = _mintPerTxt;
    }

    function crossMint(address _to, uint256 tokenQuantity) public payable whenNotPaused {
        require(msg.sender == crossmintAddress,"This function is for Crossmint only.");
        // polygon mainnet = 0x12A80DAEaf8E7D646c4adfc4B107A2f1414E2002
        // polygon mumbai  = 0xDa30ee0788276c093e686780C25f6C9431027234  

        require(publicSaleLive, "Public Sale Closed"); // Public Sale Should be active
        require(tokenQuantity <= MINT_PER_TXT, 'Exceed Per Txt limit');
        require(totalSupply() < MAX_SUPPLY, "All tokens have been minted");
        require(totalSupply() + tokenQuantity <= MAX_SUPPLY, "Minting would exceed max supply"); // Total Minted should not exceed Max Supply
        require((price * tokenQuantity) == msg.value, "Insufficient Funds Sent" ); // Amount sent should be equal to price to quantity being minted

        for(uint256 i=0; i<tokenQuantity; i++) {
            tokenMinted++;// if want to start with zero than remove then use prefix ++
            _safeMint(_to, tokenMinted); 
            emit Minted(_to, tokenQuantity, msg.value, "CrossMint");
        }
    }

    function mint(uint256 tokenQuantity) public payable whenNotPaused{
        require(publicSaleLive, "Public Sale Closed"); // Public Sale Should be active
        require(tokenQuantity <= MINT_PER_TXT, 'Exceed Per Txt limit');
        require(totalSupply() < MAX_SUPPLY, "All tokens have been minted");
        require(totalSupply() + tokenQuantity <= MAX_SUPPLY, "Minting would exceed max supply"); // Total Minted should not exceed Max Supply
        require((price * tokenQuantity) == msg.value, "Insufficient Funds Sent" ); // Amount sent should be equal to price to quantity being minted

        for(uint256 i=0; i<tokenQuantity; i++) {
            tokenMinted++;// if want to start with zero than remove then use prefix ++
            _safeMint(msg.sender, tokenMinted); 
            emit Minted(msg.sender, tokenQuantity, msg.value, "CryptoNative");
        }
    }

    function totalSupply() public view returns(uint256) {
        return tokenMinted;
    }

    function pause() public {
        _pause();
    }

    function unpause() public {
        _unpause();
    }

    function withdraw() public onlyOwner {
        require(treasuryAddress != address(0),"Treasury Address is NULL");
        (bool sent, ) = treasuryAddress.call{value: address(this).balance}("");
        require(sent, "Failed to withdraw for Treasury");
    }

}
