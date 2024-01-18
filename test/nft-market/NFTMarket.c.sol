// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console} from "forge-std/Test.sol";
import {NFTMarket} from "../../src/nft-market/NFTMarket.sol";
import {AliyaToken} from "../../src/nft-market/MyToken.sol";
import {AliyaNFT} from "../../src/nft-market/MyNFT.sol";
import {AliyaTokenRecipient} from "../../src/nft-market/TokenRecipient.sol";

contract NFTMarketTest is Test {
    NFTMarket public nftMarket;
    AliyaToken public aliyaToken;
    AliyaNFT public aliyaNFT;
    AliyaTokenRecipient public aliyaTokenRecipient;

    address public seller = address(1);
    address public buyer = address(2);

    function setUp() public {
        vm.prank(buyer);
        aliyaToken = new AliyaToken();
        aliyaNFT = new AliyaNFT();
        nftMarket = new NFTMarket(address(aliyaToken), address(aliyaNFT));
        aliyaTokenRecipient = new AliyaTokenRecipient();
    }

    function list(address _seller, uint256 tokenId, uint256 price) public {
        vm.startPrank(_seller);
        aliyaNFT.mint(_seller, tokenId);
        aliyaNFT.approve(address(nftMarket), tokenId);
        nftMarket.list(tokenId, price);
        vm.stopPrank();
    }

    function buy(address _buyer, uint256 tokenId, uint256 price) public {
        vm.startPrank(_buyer);
        aliyaToken.approve(address(nftMarket), price);
        nftMarket.buy(tokenId, price);
        vm.stopPrank();
    }

    function testList() public {
        uint256 tokenId = 1;

        list(seller, tokenId, 1000);

        assertEq(nftMarket.tokenIdPrice(tokenId), 1000);
        assertEq(nftMarket.tokenSeller(tokenId), address(1));
    }

    function testBuy() public {
        uint256 tokenId = 1;

        list(seller, tokenId, 1000);
        buy(buyer, tokenId, 1000);

        assertEq(aliyaNFT.ownerOf(tokenId), buyer);
        assertEq(aliyaToken.balanceOf(seller), 1000);
    }

    function testCallOnERC20Received() public {
        uint256 tokenId = 1;

        list(seller, tokenId, 1000);

        vm.startPrank(buyer);

        aliyaToken.transferWithCallback(
            address(aliyaTokenRecipient),
            1000,
            abi.encode(address(nftMarket), tokenId)
        );

        vm.stopPrank();

        assertEq(aliyaNFT.ownerOf(tokenId), buyer);
        assertEq(aliyaToken.balanceOf(seller), 1000);
    }

    
}
