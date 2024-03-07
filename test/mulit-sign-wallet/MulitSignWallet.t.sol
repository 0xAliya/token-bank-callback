// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../../src/mulit-sig-wallet/MulitSigWallet.sol";

contract MulitSignWalletTest is Test {
    MulitSigWallet public wallet;

    address[] public owners;

    function setUp() public {
        owners.push(makeAddr("owenr1"));
        owners.push(makeAddr("owenr2"));
        owners.push(makeAddr("owenr3"));

        payable(owners[0]).transfer(1000);
        payable(owners[1]).transfer(1000);
        payable(owners[2]).transfer(1000);

        wallet = new MulitSigWallet(owners, 2);
    }

    function testDeposit() public {
        vm.prank(owners[0]);
        payable(address(wallet)).transfer(1000);
        assertEq(address(wallet).balance, 1000);
    }

    function testApprove() public {
        vm.startPrank(owners[0]);
        payable(address(wallet)).transfer(1000);
        assertEq(address(wallet).balance, 1000);

        wallet.submit(owners[1], 100, "0x");
        wallet.approve(0);
        assertEq(wallet.getComfirmations(0), 1);
        vm.stopPrank();
    }

    function testExecute() public {
        vm.startPrank(owners[0]);
        payable(address(wallet)).transfer(1000);

        wallet.submit(owners[1], 100, "0x");
        wallet.approve(0);
        vm.stopPrank();

        assertEq(wallet.getComfirmations(0), 1);

        vm.startPrank(owners[1]);
        wallet.approve(0);
        wallet.execute(0);
        vm.stopPrank();

        assertEq(owners[1].balance, 1100);
        assertEq(address(wallet).balance, 900);
    }

    function testRevoke() public {
        vm.startPrank(owners[0]);
        payable(address(wallet)).transfer(1000);
        assertEq(address(wallet).balance, 1000);

        wallet.submit(owners[1], 100, "0x");
        wallet.approve(0);
        wallet.revoke(0);
        
        assertEq(wallet.getComfirmations(0), 0);
        vm.stopPrank();
    }

    function testFailExecuteWhenNotEnoughConfirmations() public {
        vm.prank(owners[0]);
        payable(address(wallet)).transfer(1000);
        assertEq(address(wallet).balance, 1000);

        wallet.submit(owners[1], 100, "0x");
        wallet.approve(0);
        assertEq(wallet.getComfirmations(0), 1);

        vm.prank(owners[1]);
        wallet.execute(0);
        assertEq(address(wallet).balance, 1000);
    }

    function testFailApproveNotOwner() public {
        wallet.submit(owners[1], 100, "0x");
        wallet.approve(0);
    } 
}
