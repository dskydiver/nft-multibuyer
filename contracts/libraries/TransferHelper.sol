// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

interface IERC721 {
    function transferFrom(address from, address to, uint256 id) external;
}

// ERC721 token transfer helper
library TransferHelper {
    function safeTransfer(address to, address nft, uint256 tokenID) internal {
        IERC721(nft).transferFrom(address(this), to, tokenID);
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}
