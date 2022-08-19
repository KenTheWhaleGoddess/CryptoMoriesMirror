// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MoriesEth is Ownable, ERC721('CryptoMories', 'CRYPTOMORIES'), ReentrancyGuard {
    address MORIES = 0x1a2F71468F656E97c2F86541E57189F59951efe7;

    address dev1 = 0x41538872240Ef02D6eD9aC45cf4Ff864349D51ED;
    address dev2 = 0x91187CBbf052F0F2DEDeC93e7b0e961636fA8043;

    mapping(uint256 => bool) minted;
    uint256 royaltyPercent = 250; // 2.5% out of 10k bps
    uint256 devShare = 1000; //10% out of 10k bps

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return ERC721(MORIES).tokenURI(tokenId);
    }

    function setRoyaltyPercent(uint256 _royaltyPercent) external onlyOwner {
        royaltyPercent = _royaltyPercent;
    }

    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    ) {
        return (address(this), _salePrice * royaltyPercent / 10000);
    }

    function withdraw() external {
        uint256 devSplit = address(this).balance * devShare / 10000;
        payable(dev1).call{value: devSplit/2}('');
        payable(dev2).call{value: devSplit/2}('');
        payable(owner()).call{value: address(this).balance}('');
    }

    function onERC721Received(address _operator, address _from, uint256 tokenId, bytes calldata) external nonReentrant returns (bytes4) {
        if (msg.sender == MORIES) {
            if(minted[tokenId]) {
                safeTransferFrom(address(this), _from, tokenId);
            } else {
                minted[tokenId] = true;
                _safeMint(_from, tokenId);
            }
            emit MorieSwapped1(tokenId);
        }
        return IERC721Receiver.onERC721Received.selector;
    }
    
    function setDevs(address _dev1, address _dev2) external {
        require(msg.sender == dev1 || msg.sender == dev2, "not a dev");
        dev1 = _dev1;
        dev2 = _dev2;
    }
    function setDevShare(uint256 newDevShare) external {
        require(msg.sender == dev1 || msg.sender == dev2, "not a dev");
        devShare = newDevShare;
    }

    event MorieSwapped1(uint256 tokenId);
    event MorieSwapped2(uint256 tokenId);
}
