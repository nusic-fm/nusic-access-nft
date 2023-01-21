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

    string public platinumDefaultURI = "https://gateway.pinata.cloud/ipfs/QmdjqFCk6tRHSfkZpmv7MQ4oKM6BfRQ67gDRrFD6HdxakQ/platinum.json";
    string public goldDefaultURI = "https://gateway.pinata.cloud/ipfs/QmdjqFCk6tRHSfkZpmv7MQ4oKM6BfRQ67gDRrFD6HdxakQ/gold.json";
    string public vipDefaultURI = "https://gateway.pinata.cloud/ipfs/QmdjqFCk6tRHSfkZpmv7MQ4oKM6BfRQ67gDRrFD6HdxakQ/vip.json";

    address public treasuryAddress;
    address public managerAddress;
    uint256 public tokenMinted;
    address public crossmintAddress;

    uint256 public constant PLATINUM_TOKEN_START = 1;
    uint256 public constant PLATINUM_TOKEN_END = 15;
    uint256 public constant GOLD_TOKEN_START = 16;
    uint256 public constant GOLD_TOKEN_END = 55;
    uint256 public constant VIP_TOKEN_START = 56;
    uint256 public constant VIP_TOKEN_END = 120;
    
    uint256 public platinumTokenCounter = 1;
    uint256 public goldTokenCounter = 16;
    uint256 public vipTokenCounter = 56;
    
    uint256 public minimumPlatinumTokenPrice = 0.0001 ether;
    uint256 public goldTokenPrice = 0.00001 ether;
    uint256 public vipTokenPrice = 0.000001 ether;
    
    uint256 public MAX_SUPPLY = 120;
    uint256 public MINT_PER_TXT = 5; // Mint per Transaction
    bool public publicSaleLive = true;
    bool public revealed = false;



    event PlatinumTokenMinted(address indexed to, uint256 tokenId, uint256 amountTransfered, string _type);
    event GoldTokenMinted(address indexed to, uint256 tokenId, uint256 amountTransfered, string _type);
    event VIPTokenMinted(address indexed to, uint256 tokenId, uint256 amountTransfered, string _type);
    
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        // treasuryAddress = 0x7037a3B32A68d532318c94243ba3145435f7a300; // polygon mainnet
        treasuryAddress = msg.sender;
        //crossmintAddress = 0x12A80DAEaf8E7D646c4adfc4B107A2f1414E2002; // polygon mainnet
        crossmintAddress = 0xDa30ee0788276c093e686780C25f6C9431027234;
        managerAddress = 0x07C920eA4A1aa50c8bE40c910d7c4981D135272B; 
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

    function toggleReveal() public onlyOwnerOrManager {
        revealed = !revealed;
    }
    
    function setMinimumPlatinumTokenPrice(uint256 _minimumPlatinumTokenPrice) public onlyOwnerOrManager {
        require(_minimumPlatinumTokenPrice > 0, "Price can not be zero");
        minimumPlatinumTokenPrice = _minimumPlatinumTokenPrice;
    }

    function setGoldTokenPrice(uint256 _goldTokenPrice) public onlyOwnerOrManager {
        require(_goldTokenPrice > 0, "Price can not be zero");
        goldTokenPrice = _goldTokenPrice;
    }

    function setVipTokenPrice(uint256 _vipTokenPrice) public onlyOwnerOrManager {
        require(_vipTokenPrice > 0, "Price can not be zero");
        vipTokenPrice = _vipTokenPrice;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Token does not exists");
        if(revealed == false) {
            if(tokenId >= PLATINUM_TOKEN_START && tokenId <= PLATINUM_TOKEN_END) {
                return platinumDefaultURI;
            }
            else if(tokenId >= GOLD_TOKEN_START && tokenId <= GOLD_TOKEN_END) {
                return goldDefaultURI;
            }
            else {
                return vipDefaultURI;
            }
        }
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(),".json")) : "";
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

    function platinumTokenCrossMint(address _to, uint256 tokenQuantity) public payable whenNotPaused {
        require(msg.sender == crossmintAddress,"This function is for Crossmint only.");
        // polygon mainnet = 0x12A80DAEaf8E7D646c4adfc4B107A2f1414E2002
        // polygon mumbai  = 0xDa30ee0788276c093e686780C25f6C9431027234  
        require(tokenQuantity <= MINT_PER_TXT, 'Exceed Per Txt limit');
        require(totalSupply() < MAX_SUPPLY, "All tokens have been minted");

        require(platinumTokenCounter >= PLATINUM_TOKEN_START && platinumTokenCounter <= PLATINUM_TOKEN_END, "All Platinum tokens have been minted");
        require((platinumTokenCounter + tokenQuantity) >= PLATINUM_TOKEN_START && (platinumTokenCounter + tokenQuantity) <= PLATINUM_TOKEN_END, "All Platinum tokens have been minted");
        
        require(totalSupply() + tokenQuantity <= MAX_SUPPLY, "Minting would exceed max supply"); // Total Minted should not exceed Max Supply
        //require((minimumPlatinumTokenPrice * tokenQuantity) == msg.value, "Insufficient Funds Sent" ); // Amount sent should be equal to price to quantity being minted
        require(msg.value >= (minimumPlatinumTokenPrice * tokenQuantity), "Insufficient Funds Sent" );

        for(uint256 i=0; i<tokenQuantity; i++) {
            _safeMint(_to, platinumTokenCounter); 
            emit PlatinumTokenMinted(_to, platinumTokenCounter, msg.value, "CrossMint");
            platinumTokenCounter++;
            tokenMinted++;
        }
    }

    function platinumTokenNativeMint(address _to, uint256 tokenQuantity) public payable whenNotPaused {
        //require(msg.sender == crossmintAddress,"This function is for Crossmint only.");
        // polygon mainnet = 0x12A80DAEaf8E7D646c4adfc4B107A2f1414E2002
        // polygon mumbai  = 0xDa30ee0788276c093e686780C25f6C9431027234  
        require(tokenQuantity <= MINT_PER_TXT, 'Exceed Per Txt limit');
        require(totalSupply() < MAX_SUPPLY, "All tokens have been minted");

        require(platinumTokenCounter >= PLATINUM_TOKEN_START && platinumTokenCounter <= PLATINUM_TOKEN_END, "All Platinum tokens have been minted");
        require((platinumTokenCounter + tokenQuantity) >= PLATINUM_TOKEN_START && (platinumTokenCounter + tokenQuantity) <= PLATINUM_TOKEN_END, "All Platinum tokens have been minted");
        
        require(totalSupply() + tokenQuantity <= MAX_SUPPLY, "Minting would exceed max supply"); // Total Minted should not exceed Max Supply
        //require((minimumPlatinumTokenPrice * tokenQuantity) == msg.value, "Insufficient Funds Sent" ); // Amount sent should be equal to price to quantity being minted
        require(msg.value >= (minimumPlatinumTokenPrice * tokenQuantity), "Insufficient Funds Sent" );

        for(uint256 i=0; i<tokenQuantity; i++) {
            _safeMint(_to, platinumTokenCounter); 
            emit PlatinumTokenMinted(_to, platinumTokenCounter, msg.value, "CryptoNative");
            platinumTokenCounter++;
            tokenMinted++;
        }
    }

    function goldTokenCrossMint(address _to, uint256 tokenQuantity) public payable whenNotPaused {
        require(msg.sender == crossmintAddress,"This function is for Crossmint only.");
        // polygon mainnet = 0x12A80DAEaf8E7D646c4adfc4B107A2f1414E2002
        // polygon mumbai  = 0xDa30ee0788276c093e686780C25f6C9431027234  
        require(tokenQuantity <= MINT_PER_TXT, 'Exceed Per Txt limit');
        require(totalSupply() < MAX_SUPPLY, "All tokens have been minted");

        require(goldTokenCounter >= GOLD_TOKEN_START && goldTokenCounter <= GOLD_TOKEN_END, "All Gold tokens have been minted");
        require((goldTokenCounter + tokenQuantity) >= GOLD_TOKEN_START && (goldTokenCounter + tokenQuantity) <= GOLD_TOKEN_END, "All Gold tokens have been minted");
        
        require(totalSupply() + tokenQuantity <= MAX_SUPPLY, "Minting would exceed max supply"); // Total Minted should not exceed Max Supply
        require((goldTokenPrice * tokenQuantity) == msg.value, "Insufficient Funds Sent" ); // Amount sent should be equal to price to quantity being minted

        for(uint256 i=0; i<tokenQuantity; i++) {
            _safeMint(_to, goldTokenCounter); 
            emit GoldTokenMinted(_to, tokenQuantity, msg.value, "CrossMint");
            goldTokenCounter++;
            tokenMinted++;
        }
    }

    function goldTokenNativeMint(address _to, uint256 tokenQuantity) public payable whenNotPaused {
        //require(msg.sender == crossmintAddress,"This function is for Crossmint only.");
        // polygon mainnet = 0x12A80DAEaf8E7D646c4adfc4B107A2f1414E2002
        // polygon mumbai  = 0xDa30ee0788276c093e686780C25f6C9431027234  
        require(tokenQuantity <= MINT_PER_TXT, 'Exceed Per Txt limit');
        require(totalSupply() < MAX_SUPPLY, "All tokens have been minted");

        require(goldTokenCounter >= GOLD_TOKEN_START && goldTokenCounter <= GOLD_TOKEN_END, "All Gold tokens have been minted");
        require((goldTokenCounter + tokenQuantity) >= GOLD_TOKEN_START && (goldTokenCounter + tokenQuantity) <= GOLD_TOKEN_END, "All Gold tokens have been minted");
        
        require(totalSupply() + tokenQuantity <= MAX_SUPPLY, "Minting would exceed max supply"); // Total Minted should not exceed Max Supply
        require((goldTokenPrice * tokenQuantity) == msg.value, "Insufficient Funds Sent" ); // Amount sent should be equal to price to quantity being minted

        for(uint256 i=0; i<tokenQuantity; i++) {
            _safeMint(_to, goldTokenCounter); 
            emit GoldTokenMinted(_to, tokenQuantity, msg.value, "CryptoNative");
            goldTokenCounter++;
            tokenMinted++;
        }
    }

    function vipTokenCrossMint(address _to, uint256 tokenQuantity) public payable whenNotPaused {
        require(msg.sender == crossmintAddress,"This function is for Crossmint only.");
        // polygon mainnet = 0x12A80DAEaf8E7D646c4adfc4B107A2f1414E2002
        // polygon mumbai  = 0xDa30ee0788276c093e686780C25f6C9431027234  
        require(tokenQuantity <= MINT_PER_TXT, 'Exceed Per Txt limit');
        require(totalSupply() < MAX_SUPPLY, "All tokens have been minted");

        require(vipTokenCounter >= VIP_TOKEN_START && vipTokenCounter <= VIP_TOKEN_END, "All VIP tokens have been minted");
        require((vipTokenCounter + tokenQuantity) >= VIP_TOKEN_START && (vipTokenCounter + tokenQuantity) <= VIP_TOKEN_END, "All VIP tokens have been minted");
        
        require(totalSupply() + tokenQuantity <= MAX_SUPPLY, "Minting would exceed max supply"); // Total Minted should not exceed Max Supply
        require((vipTokenPrice * tokenQuantity) == msg.value, "Insufficient Funds Sent" ); // Amount sent should be equal to price to quantity being minted

        for(uint256 i=0; i<tokenQuantity; i++) {
            _safeMint(_to, vipTokenCounter); 
            emit VIPTokenMinted(_to, vipTokenCounter, msg.value, "CrossMint");
            vipTokenCounter++;
            tokenMinted++;
        }
    }

    function vipTokenNativeMint(address _to, uint256 tokenQuantity) public payable whenNotPaused {
        //require(msg.sender == crossmintAddress,"This function is for Crossmint only.");
        // polygon mainnet = 0x12A80DAEaf8E7D646c4adfc4B107A2f1414E2002
        // polygon mumbai  = 0xDa30ee0788276c093e686780C25f6C9431027234  
        require(tokenQuantity <= MINT_PER_TXT, 'Exceed Per Txt limit');
        require(totalSupply() < MAX_SUPPLY, "All tokens have been minted");

        require(vipTokenCounter >= VIP_TOKEN_START && vipTokenCounter <= VIP_TOKEN_END, "All VIP tokens have been minted");
        require((vipTokenCounter + tokenQuantity) >= VIP_TOKEN_START && (vipTokenCounter + tokenQuantity) <= VIP_TOKEN_END, "All VIP tokens have been minted");
        
        require(totalSupply() + tokenQuantity <= MAX_SUPPLY, "Minting would exceed max supply"); // Total Minted should not exceed Max Supply
        require((vipTokenPrice * tokenQuantity) == msg.value, "Insufficient Funds Sent" ); // Amount sent should be equal to price to quantity being minted

        for(uint256 i=0; i<tokenQuantity; i++) {
            _safeMint(_to, vipTokenCounter); 
            emit VIPTokenMinted(_to, vipTokenCounter, msg.value, "CryptoNative");
            vipTokenCounter++;
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
