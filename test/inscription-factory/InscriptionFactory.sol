// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console} from "forge-std/Test.sol";
import {InscriptionFactory} from "../../src/inscription-factory/InscriptionFactory.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract InscriptionFactoryTest is Test {
    InscriptionFactory public inscriptionFactory;
    address public admin = makeAddr("admin");
    address public minter = makeAddr("minter");

    function setUp() public {
        inscriptionFactory = new InscriptionFactory();
    }

    function testDeployInscription() public {
        inscriptionFactory.deployInscription("test", "test", 100000, 1000);
        assertEq(inscriptionFactory.checkIsDeployed("test"), true);
    }

    function testFailDeployInscription() public {
        inscriptionFactory.deployInscription("test", "test", 100, 1000);
    }

    function testFailRepeatDeployInscription() public {
        inscriptionFactory.deployInscription("test", "test", 100000, 1000);
        inscriptionFactory.deployInscription("test", "test", 100000, 1000);
    }

    function testFailNameOverFlow() public {
        inscriptionFactory.deployInscription("testtest", "test", 100000, 1000);
    }

    function testMint() public {
        inscriptionFactory.deployInscription("test", "test", 100000, 1000);
        address tokenAddress = inscriptionFactory.getTokenAddress("test");

        vm.startPrank(minter);
        inscriptionFactory.mint("test");
        inscriptionFactory.mint("test");
        inscriptionFactory.mint("test");
        vm.stopPrank();

        assertEq(IERC20(tokenAddress).balanceOf(minter), 3000);
    }

    function testFailOverMint() public {
        inscriptionFactory.deployInscription("test", "test", 100000, 50000);
        inscriptionFactory.mint("test");
        inscriptionFactory.mint("test");
        inscriptionFactory.mint("test");
    }
}
