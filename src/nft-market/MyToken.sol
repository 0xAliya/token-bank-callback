//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface TokenRecipient {
    function tokensReceived(
        address sender,
        uint amount,
        bytes memory data
    ) external returns (bool);
}

contract AliyaToken is ERC20 {
    using Address for address;

    constructor() ERC20("Aliya", "aliya") {
        _mint(msg.sender, 100000 * 10 ** 18);
    }

    function transferWithCallback(
        address recipient,
        uint256 amount,
        bytes memory data
    ) external returns (bool) {
        _transfer(msg.sender, recipient, amount);

        if (recipient.isContract()) {
            bool rv = TokenRecipient(recipient).tokensReceived(
                msg.sender,
                amount,
                data
            );
            require(rv, "No tokensReceived");
        }

        return true;
    }
}
