pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "forge-std/console.sol";

interface TokenRecipient {
    function tokensReceived(
        address sender,
        uint amount,
        bytes memory data
    ) external returns (bool);
}

contract NFTMarket is TokenRecipient, IERC721Receiver {
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

    function tokensReceived(
        address sender,
        uint amount,
        bytes memory data
    ) external returns (bool) {
        uint256 tokenId = abi.decode(data, (uint256));
        IERC20(token).transfer(tokenSeller[tokenId], tokenIdPrice[tokenId]);
        IERC721(nftToken).transferFrom(address(this), sender, tokenId);
        _unlist(tokenId);
        return true;
    }

    function _unlist(uint tokenId) internal {
        delete tokenIdPrice[tokenId];
        delete tokenSeller[tokenId];
    }

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

    function buy(uint tokenId, uint amount) public {
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
        _unlist(tokenId);
    }

    function unlist(uint tokenId) external {
        require(tokenSeller[tokenId] == msg.sender, "not seller");
        IERC721(nftToken).transferFrom(address(this), msg.sender, tokenId);
        _unlist(tokenId);
    }
}
