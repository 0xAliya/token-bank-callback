// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Inscription.sol";
import "./libs/String.sol";

contract InscriptionFactory {
    using Clones for address;

    uint8 public constant TICK_SIZE = 4;

    address private _libraryAddress;

    struct Token {
        address tokenAddress;
        string name;
        string symbol;
        uint256 totalSupply;
        uint256 perMint;
    }

    mapping(string => Token) public tokens;

    event DeployInscription(
        string name,
        string symbol,
        uint256 totalSupply,
        uint256 perMint
    );

    constructor() {
        _libraryAddress = address(new Inscription());
    }

    function checkIsDeployed(string memory name) public view returns (bool) {
        return tokens[name].tokenAddress != address(0);
    }

    function deployInscription(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        uint256 perMint
    ) public returns (address) {
        string memory lowcaseName = String.toLower(name);
        require(!checkIsDeployed(lowcaseName), "token already exists");
        require(bytes(name).length == TICK_SIZE, "name must be 4");
        require(bytes(symbol).length == TICK_SIZE, "symbol must be 4");
        require(totalSupply > 0, "totalSupply must be greater than 0");
        require(perMint > 0, "perMint must be greater than 0");
        require(
            perMint <= totalSupply,
            "perMint must be less than totalSupply"
        );

        address clone = _libraryAddress.clone();

        Inscription(clone).init(name, symbol, totalSupply, perMint);

        tokens[lowcaseName] = Token(clone, name, symbol, totalSupply, perMint);

        emit DeployInscription(name, symbol, totalSupply, perMint);

        return clone;
    }

    function mint(string memory name) public {
        string memory lowcaseName = String.toLower(name);
        require(checkIsDeployed(lowcaseName), "token not exists");
        Inscription(tokens[lowcaseName].tokenAddress).mint(msg.sender);
    }

    function getLibraryAddress() public view returns (address) {
        return _libraryAddress;
    }

    function getTokenAddress(string memory name) public view returns (address) {
        string memory lowcaseName = String.toLower(name);
        require(checkIsDeployed(lowcaseName), "token not exists");
        return tokens[lowcaseName].tokenAddress;
    }
}
