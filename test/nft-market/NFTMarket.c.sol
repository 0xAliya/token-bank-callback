// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console} from "forge-std/Test.sol";
import {NFTMarket} from "../../src/nft-market/NFTMarket.sol";
import {AliyaToken} from "../../src/nft-market/MyToken.sol";
import {AliyaNFT} from "../../src/nft-market/MyNFT.sol";

contract NFTMarketTest is Test {
    NFTMarket public nftMarket;
    AliyaToken public aliyaToken;
    AliyaNFT public aliyaNFT;

    address public seller = address(1);
    address public buyer = address(2);
    address public admin = makeAddr("admin");

    function setUp() public {
        vm.startPrank(admin);
        aliyaToken = new AliyaToken();
        aliyaNFT = new AliyaNFT();
        nftMarket = new NFTMarket(address(aliyaToken), address(aliyaNFT));
        aliyaToken.transfer(buyer, 10000);
        vm.stopPrank();
    }

    function list(address _seller, uint256 tokenId, uint256 price) private {
        vm.startPrank(_seller);
        aliyaNFT.mint(_seller, tokenId);
        aliyaNFT.approve(address(nftMarket), tokenId);
        nftMarket.list(tokenId, price);
        vm.stopPrank();
    }

    function buy(address _buyer, uint256 tokenId, uint256 price) private {
        vm.startPrank(_buyer);
        aliyaToken.approve(address(nftMarket), price);
        nftMarket.buy(tokenId, price);
        vm.stopPrank();
    }

    function unlist(address _seller, uint256 tokenId) private {
        vm.startPrank(_seller);
        nftMarket.unlist(tokenId);
        vm.stopPrank();
    }

    function testList() public {
        uint256 tokenId = 1;

        list(seller, tokenId, 1000);

        assertEq(nftMarket.tokenIdPrice(tokenId), 1000);
        assertEq(nftMarket.tokenSeller(tokenId), seller);
    }

    function testBuy() public {
        uint256 tokenId = 1;

        list(seller, tokenId, 1000);
        buy(buyer, tokenId, 1000);

        assertEq(aliyaNFT.ownerOf(tokenId), buyer);
        assertEq(aliyaToken.balanceOf(seller), 1000);
    }

    function testCallOnERC20Received(uint256 tokenId, uint256 price) public {
        vm.assume(tokenId < 100);
        vm.assume(price < 10000);
        list(seller, tokenId, price);

        vm.startPrank(buyer);
        aliyaToken.transferWithCallback(
            address(nftMarket),
            price,
            abi.encode(tokenId)
        );
        vm.stopPrank();

        assertEq(aliyaNFT.ownerOf(tokenId), buyer);
        assertEq(aliyaToken.balanceOf(seller), price);
    }

    function testUnlist() public {
        uint256 tokenId = 1;

        list(seller, tokenId, 1000);
        unlist(seller, tokenId);

        assertEq(aliyaNFT.ownerOf(tokenId), seller);
        assertEq(nftMarket.tokenIdPrice(tokenId), 0);
        assertEq(nftMarket.tokenSeller(tokenId), address(0));
    }
}
