// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract AliyaNFT is ERC721 {
    uint public MAX_LIMIT = 100; // 总量

    constructor() ERC721("AliyaNFT", "aliya") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmSH3rQJprgxDYGA7T4EgmWcLu4QFunXcfQVZv3LmTk5j5/";
    }

    function mint(address to, uint256 tokenId) external {
        require(tokenId >= 0 && tokenId < MAX_LIMIT, "tokenId out of range");
        _mint(to, tokenId);
    }
}
