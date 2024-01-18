// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC1820Registry } from "./IERC1820Registry.sol";
import { IERC777Recipient } from "./IERC777Recipient.sol";

contract TokenBank is IERC777Recipient {
    using SafeERC20 for IERC20;
    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0xDC6C05506B9d221c77d62cbd5964B0209B5D0b18);
    address public owner;
    address public tokenAddress;

    mapping(address => uint256) private balances;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(address _tokenAddress) {
        owner = msg.sender;
        tokenAddress = _tokenAddress;
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw() external onlyOwner {
        uint256 totalBalance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).safeTransfer(owner, totalBalance);
        emit Withdrawal(totalBalance);
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount
    ) external override {
        balances[from] += amount;
    }
}
