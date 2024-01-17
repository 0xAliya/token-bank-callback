// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract Aliya is ERC721{
    uint public MAX_LIMIT = 100; // 总量

    // 构造函数
    constructor() ERC721("Aliya", "aliya"){
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmSH3rQJprgxDYGA7T4EgmWcLu4QFunXcfQVZv3LmTk5j5/";
    }
    
    // 铸造函数
    function mint(address to, uint tokenId) external {
        require(tokenId >= 0 && tokenId < MAX_LIMIT, "tokenId out of range");
        _mint(to, tokenId);
    }
}