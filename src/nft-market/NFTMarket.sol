pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "forge-std/console.sol";

contract NFTMarket is IERC721Receiver {
    mapping(uint => uint) public tokenIdPrice;
    mapping(uint => address) public tokenSeller;
    address public immutable token;
    address public immutable nftToken;

    constructor(address _token, address _nftToken) {
        token = _token;
        nftToken = _nftToken;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // approve(address to, uint256 tokenId) first
    function list(uint tokenID, uint amount) public {
        require(IERC721(nftToken).ownerOf(tokenID) == msg.sender, "not owner");
        IERC721(nftToken).safeTransferFrom(
            msg.sender,
            address(this),
            tokenID,
            ""
        );
        tokenIdPrice[tokenID] = amount;
        tokenSeller[tokenID] = msg.sender;
    }

    function buy(uint tokenId, uint amount) external {
        require(amount >= tokenIdPrice[tokenId], "low price");

        require(
            IERC721(nftToken).ownerOf(tokenId) == address(this),
            "aleady selled"
        );

        IERC20(token).transferFrom(
            msg.sender,
            tokenSeller[tokenId],
            tokenIdPrice[tokenId]
        );
        IERC721(nftToken).transferFrom(address(this), msg.sender, tokenId);
    }

    function unlist(uint tokenId) external {
        require(tokenSeller[tokenId] == msg.sender, "not seller");
        IERC721(nftToken).transferFrom(address(this), msg.sender, tokenId);
        delete tokenIdPrice[tokenId];
        delete tokenSeller[tokenId];
    }
}
