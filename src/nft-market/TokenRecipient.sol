// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "forge-std/console.sol";

interface TokenRecipient {
    function tokensReceived(
        address sender,
        uint amount,
        bytes memory data
    ) external returns (bool);
}

interface INFTMarket is IERC721Receiver {
    function nftToken() external view returns (address);

    function buy(uint tokenId, uint amount) external view returns (bool);
}

contract AliyaTokenRecipient is TokenRecipient {
    function tokensReceived(
        address sender,
        uint amount,
        bytes memory data
    ) external returns (bool) {
        console.log("AliyaTokenRecipient.tokensReceived");
        // 解析 data 数据结构
        (address nftMarket, uint256 tokenId) = abi.decode(
            data,
            (address, uint256)
        );

        IERC20(msg.sender).approve(nftMarket, amount);
        // 调用 NFTMarket 合约的 buy 方法
        // 改为非 static call
        nftMarket.call{value: 0}(
            abi.encodeWithSignature("buy(uint256,uint256)", tokenId, amount)
        );
        
        IERC721(INFTMarket(nftMarket).nftToken()).safeTransferFrom(
            address(this),
            sender,
            tokenId
        );
        return true;
    }
}
