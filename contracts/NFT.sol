// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension and Enumerable extension.
 */
contract NFT is Context, ERC721Enumerable, Ownable {
    /// Provenance hash
    string public PROVENANCE_HASH;

    /// Base URI
    string private _metropassBaseURI;

    /// Starting Index
    uint256 public startingIndex;

    /// Max number of NFTs and restrictions per wallet
    uint256 public constant MAX_SUPPLY = 3333;
    uint256 private _maxPerWallet;
    uint256 public tokenPrice;
    bool private startingIndexSet;

    /// Stores the number of minted tokens by user
    mapping(address => uint256) public _mintedByAddress;

    constructor(
        string memory _baseURI
    ) ERC721("Loveless City Metropass", "$LOVE") Ownable(msg.sender) {
        _metropassBaseURI = _baseURI;

        _maxPerWallet = 1;
        tokenPrice = 0.001 ether;
    }

    /// Public function to purchase $LOVE tokens
    function mint(uint256 tokensNumber) public payable {
        require(tokensNumber > 0, "Wrong amount requested");
        require(
            totalSupply() + tokensNumber <= MAX_SUPPLY,
            "You tried to mint more than the max allowed"
        );
        require(
            _mintedByAddress[_msgSender()] + tokensNumber <= _maxPerWallet,
            "You have hit the max tokens per wallet"
        );
        require(
            tokensNumber * tokenPrice == msg.value,
            "You have not sent enough ETH"
        );

        _mintedByAddress[_msgSender()] += tokensNumber;

        for (uint256 i = 0; i < tokensNumber; i++) {
            _safeMint(_msgSender(), totalSupply());
        }
    }

    /// Withdraws collected ether from the contract to the owner address
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
}
