// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Inscription is ERC20 {
    string private _initName;
    string private _initSymbol;
    uint256 private _initTotalSupply;
    uint256 private _initPerMint;
    bool private _hasInit;

    constructor() ERC20("", "") {
    }

    function name() public view override returns (string memory) {
        return _initName;
    }

    function symbol() public view override returns (string memory) {
        return _initSymbol;
    }

    function init(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        uint256 _perMint
    ) public {
        require(!_hasInit, "already init");
        _hasInit = true;

        _initName = _name;
        _initSymbol = _symbol;
        _initTotalSupply = _totalSupply;
        _initPerMint = _perMint;
    }

    function mint(address to) public {
        if (totalSupply() + _initPerMint > _initTotalSupply) {
            revert("totalSupply exceeded");
        }

        _mint(to, _initPerMint);
    }
}
