// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./libraries/TransferHelper.sol";

interface INFTMinter {
    function initialize(address _owner) external payable;

    function buy(address NFT, bytes memory _params) external payable;

    function withdraw(uint256 tokenID, address to, address NFT) external;

    function getTokenID(address _NFT) external view returns (uint256);

    function withdrawAllETH(address to) external;
}

contract MinterFactory is Ownable {
    address public minter;
    address[] public preClones;
    uint currentIndex;

    event NewClone(address _newClone);

    using Clones for address;

    constructor(address _minter, uint256 preClonesNum) Ownable(msg.sender) {
        minter = _minter;
        for (uint256 i = 0; i < preClonesNum; i++) {
            address identicalChild = minter.clone();
            INFTMinter(identicalChild).initialize(msg.sender);
            preClones.push(identicalChild);

            emit NewClone(identicalChild);
        }
    }

    function preClone(uint256 num) external onlyOwner {
        for (uint256 i = 0; i < num; i++) {
            address identicalChild = minter.clone();
            INFTMinter(identicalChild).initialize(msg.sender);
            preClones.push(identicalChild);

            emit NewClone(identicalChild);
        }
    }

    function batchMint(
        uint256 walletNum,
        uint256 ethPerWallet,
        address nft,
        bytes memory data
    ) external payable onlyOwner {
        require(
            walletNum <= numberOfClones(),
            "BuyerFactory: not enough clones"
        );
        require(
            ethPerWallet * walletNum <= msg.value,
            "BuyerFactory: not enought fund"
        );

        for (uint256 i = 0; i < walletNum; i++) {
            INFTMinter(preClones[i]).buy{value: ethPerWallet}(nft, data);
        }
    }

    function withdrawAllETH(address to) external onlyOwner {
        for (uint256 i = 0; i < numberOfClones(); i++) {
            INFTMinter(preClones[i]).withdrawAllETH(to);
        }
        TransferHelper.safeTransferETH(to, address(this).balance);
    }

    function withdraw(address _minter, address nft, address to) public {
        INFTMinter(_minter).withdraw(
            INFTMinter(_minter).getTokenID(nft),
            to,
            nft
        );
    }

    function numberOfClones() public view returns (uint256 number) {
        number = preClones.length;
    }

    function allClones() external view returns (address[] memory) {
        return preClones;
    }
}
