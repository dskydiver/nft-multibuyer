// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "./libraries/TransferHelper.sol";

import "hardhat/console.sol";

interface ITarget {
    function ownerOf(uint256 tokenID) external view returns (address);

    function totalSupply() external view returns (uint256);
}

contract NFTMinter {
    address public factoryAddress;
    address public factoryOwner;

    modifier onlyFactoryOrOwner() {
        require(
            msg.sender == factoryAddress || msg.sender == factoryOwner,
            "Unauthorized"
        );
        _;
    }

    constructor() {}

    function initialize(address _factoryOwner) public {
        require(factoryAddress == address(0), "Already initialized");
        factoryAddress = msg.sender; // Assuming the factory contract is deploying this
        factoryOwner = _factoryOwner;
    }

    function buy(address NFT, bytes memory data) external payable {
        // Calling the function
        (bool success, ) = NFT.call{value: msg.value}(data);
        require(success, "Call failed");
    }

    function withdraw(uint256 tokenID, address to, address NFT) external {
        TransferHelper.safeTransfer(NFT, to, tokenID);
    }

    function getTokenID(address _NFT) external view returns (uint256 id) {
        for (uint256 i = 1; i < ITarget(_NFT).totalSupply(); i++) {
            if (ITarget(_NFT).ownerOf(i) == address(this)) {
                id = i;
                break;
            }
        }
    }

    function withdrawAllETH(address to) external onlyFactoryOrOwner {
        TransferHelper.safeTransferETH(to, address(this).balance);
    }

    event Received();

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4) {
        _operator;
        _from;
        _tokenId;
        _data;
        emit Received();
        return 0x150b7a02;
    }
}
