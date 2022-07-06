// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract TransferOutside {
    event BeginTransfer(address indexed from, bytes to,
               IERC721 indexed nft, uint256 indexed tokenId);
    address private owner;
    constructor(address _owner) {
        owner = _owner;
    }
    function beginTransfer(IERC721 nft,
                uint256 tokenId,
                bytes memory to)
            public {
       nft.safeTransferFrom(msg.sender, owner, tokenId);
       emit BeginTransfer(msg.sender, to, nft, tokenId);
    }
}
