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

    uint256 public constant FREE_TOKEN_START = 1;
    uint256 public constant FREE_TOKEN_END = 30;
    uint256 public constant PLATINUM_TOKEN_START = 31;
    uint256 public constant PLATINUM_TOKEN_END = 70;
    uint256 public constant GOLD_TOKEN_START = 71;
    uint256 public constant GOLD_TOKEN_END = 100;

    uint256 public freeTokenCounter = 1;
    uint256 public platinumTokenCounter = 31;
    uint256 public goldTokenCounter = 71;

    uint256 public freeTokenPrice = 0 ether;
    uint256 public platinumTokenPrice = 1 ether;
    uint256 public goldTokenPrice = 3 ether;
    
    uint256 public MAX_SUPPLY = 100;
    uint256 public MINT_PER_TXT = 5; // Mint per Transaction
    bool public publicSaleLive = true;
    

    event FreeTokenMinted(address indexed to, uint256 tokenId, uint256 amountTransfered);
    event PlatinumTokenMinted(address indexed to, uint256 tokenId, uint256 amountTransfered);
    event GoldTokenMinted(address indexed to, uint256 tokenId, uint256 amountTransfered);
    
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

/*
    function setFreeTokenPrice(uint256 _freeTokenPrice) public onlyOwnerOrManager {
        require(_freeTokenPrice > 0, "Price can not be zero");
        freeTokenPrice = _freeTokenPrice;
    }
*/    
    function setPlatinumTokenPrice(uint256 _platinumTokenPrice) public onlyOwnerOrManager {
        require(_platinumTokenPrice > 0, "Price can not be zero");
        platinumTokenPrice = _platinumTokenPrice;
    }

    function setGoldTokenPrice(uint256 _goldTokenPrice) public onlyOwnerOrManager {
        require(_goldTokenPrice > 0, "Price can not be zero");
        goldTokenPrice = _goldTokenPrice;
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

    function freeTokenMint(address _to, uint256 tokenQuantity) public payable whenNotPaused {
        require(msg.sender == crossmintAddress,"This function is for Crossmint only.");
        // polygon mainnet = 0x12A80DAEaf8E7D646c4adfc4B107A2f1414E2002
        // polygon mumbai  = 0xDa30ee0788276c093e686780C25f6C9431027234  
        require(tokenQuantity <= MINT_PER_TXT, 'Exceed Per Txt limit');
        require(totalSupply() < MAX_SUPPLY, "All tokens have been minted");

        require(freeTokenCounter >= FREE_TOKEN_START && freeTokenCounter <= FREE_TOKEN_END, "All tokens have been minted");
        require((freeTokenCounter + tokenQuantity) >= FREE_TOKEN_START && (freeTokenCounter + tokenQuantity) <= FREE_TOKEN_END, "All tokens have been minted");
        
        require(totalSupply() + tokenQuantity <= MAX_SUPPLY, "Minting would exceed max supply"); // Total Minted should not exceed Max Supply
        require((freeTokenPrice * tokenQuantity) == msg.value, "Insufficient Funds Sent" ); // Amount sent should be equal to price to quantity being minted

        for(uint256 i=0; i<tokenQuantity; i++) {
            _safeMint(_to, freeTokenCounter); 
            emit FreeTokenMinted(_to, freeTokenCounter, msg.value);
            freeTokenCounter++;
            tokenMinted++;
        }
    }

    function platinumTokenMint(address _to, uint256 tokenQuantity) public payable whenNotPaused {
        require(msg.sender == crossmintAddress,"This function is for Crossmint only.");
        // polygon mainnet = 0x12A80DAEaf8E7D646c4adfc4B107A2f1414E2002
        // polygon mumbai  = 0xDa30ee0788276c093e686780C25f6C9431027234  
        require(tokenQuantity <= MINT_PER_TXT, 'Exceed Per Txt limit');
        require(totalSupply() < MAX_SUPPLY, "All tokens have been minted");

        require(platinumTokenCounter >= PLATINUM_TOKEN_START && platinumTokenCounter <= PLATINUM_TOKEN_END, "All tokens have been minted");
        require((platinumTokenCounter + tokenQuantity) >= PLATINUM_TOKEN_START && (platinumTokenCounter + tokenQuantity) <= PLATINUM_TOKEN_END, "All tokens have been minted");
        
        require(totalSupply() + tokenQuantity <= MAX_SUPPLY, "Minting would exceed max supply"); // Total Minted should not exceed Max Supply
        require((platinumTokenPrice * tokenQuantity) == msg.value, "Insufficient Funds Sent" ); // Amount sent should be equal to price to quantity being minted

        for(uint256 i=0; i<tokenQuantity; i++) {
            _safeMint(_to, platinumTokenCounter); 
            emit PlatinumTokenMinted(_to, platinumTokenCounter, msg.value);
            platinumTokenCounter++;
            tokenMinted++;
        }
    }

    function goldTokenMint(address _to, uint256 tokenQuantity) public payable whenNotPaused {
        require(msg.sender == crossmintAddress,"This function is for Crossmint only.");
        // polygon mainnet = 0x12A80DAEaf8E7D646c4adfc4B107A2f1414E2002
        // polygon mumbai  = 0xDa30ee0788276c093e686780C25f6C9431027234  
        require(tokenQuantity <= MINT_PER_TXT, 'Exceed Per Txt limit');
        require(totalSupply() < MAX_SUPPLY, "All tokens have been minted");

        require(goldTokenCounter >= GOLD_TOKEN_START && goldTokenCounter <= GOLD_TOKEN_END, "All tokens have been minted");
        require((goldTokenCounter + tokenQuantity) >= GOLD_TOKEN_START && (platinumTokenCounter + tokenQuantity) <= GOLD_TOKEN_END, "All tokens have been minted");
        
        require(totalSupply() + tokenQuantity <= MAX_SUPPLY, "Minting would exceed max supply"); // Total Minted should not exceed Max Supply
        require((goldTokenPrice * tokenQuantity) == msg.value, "Insufficient Funds Sent" ); // Amount sent should be equal to price to quantity being minted

        for(uint256 i=0; i<tokenQuantity; i++) {
            _safeMint(_to, goldTokenCounter); 
            emit GoldTokenMinted(_to, tokenQuantity, msg.value);
            goldTokenCounter++;
            tokenMinted++;
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
