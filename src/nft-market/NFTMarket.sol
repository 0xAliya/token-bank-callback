pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface TokenRecipient {
    function tokensReceived(
        address sender,
        uint amount,
        bytes memory data
    ) external returns (bool);
}

contract NFTMarket is TokenRecipient, IERC721Receiver {
    struct ListState {
        uint isList;
        address seller;
        uint256 price;
    }

    address public token; // 0
    address public nftToken; // 1
    address public owner; // 2

    ListState[100] public listState;

    event List(address indexed seller, uint256 indexed tokenId, uint256 price);
    event Buy(address indexed buyer, uint256 indexed tokenId, uint256 price);
    event Unlist(address indexed seller, uint256 indexed tokenId);

    constructor(address _token, address _nftToken) {
        token = _token;
        nftToken = _nftToken;
        owner = msg.sender;
    }

    function readOwner() public view returns (address) {
        bytes32 data;
        assembly {
            data := sload(2)
        }
        return address(uint160(uint256(data)));
    }

    function setOwner(address _owner) public {
        assembly {
            sstore(2, _owner)
        }
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
        IERC20(token).transfer(getTokenInfo(tokenId).seller, amount);
        IERC721(nftToken).transferFrom(address(this), sender, tokenId);
        _unlist(tokenId);
        return true;
    }

    function _unlist(uint tokenId) internal {
        listState[tokenId].isList = 0;
        listState[tokenId].seller = address(0);
        listState[tokenId].price = 0;
    }

    function list(uint tokenID, uint amount) public {
        require(IERC721(nftToken).ownerOf(tokenID) == msg.sender, "not owner");
        IERC721(nftToken).safeTransferFrom(
            msg.sender,
            address(this),
            tokenID,
            ""
        );
        listState[tokenID].isList = 1;
        listState[tokenID].seller = msg.sender;
        listState[tokenID].price = amount;
        emit List(msg.sender, tokenID, amount);
    }

    function buy(uint tokenId, uint amount) public {
        require(amount >= getTokenInfo(tokenId).price, "low price");

        require(
            IERC721(nftToken).ownerOf(tokenId) == address(this),
            "aleady selled"
        );

        IERC20(token).transferFrom(
            msg.sender,
            getTokenInfo(tokenId).seller,
            getTokenInfo(tokenId).price
        );
        IERC721(nftToken).transferFrom(address(this), msg.sender, tokenId);
        _unlist(tokenId);
        emit Buy(msg.sender, tokenId, amount);
    }

    function unlist(uint tokenId) external {
        require(getTokenInfo(tokenId).seller == msg.sender, "not seller");
        IERC721(nftToken).transferFrom(address(this), msg.sender, tokenId);
        _unlist(tokenId);
        emit Unlist(msg.sender, tokenId);
    }

    function getTokenInfo(uint tokenId) public view returns (ListState memory) {
        return listState[tokenId];
    }

    function getListState() public view returns (ListState[100] memory) {
        return listState;
    }
}
