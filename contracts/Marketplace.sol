//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./KadyrovERC721.sol";

contract Marketplace is AccessControl {
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _totalAmount;

    IERC20 private ERC20Token;
    KadyrovERC721 public nftContract;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint256 private _auctionDuration; // 3 days
    uint256 private _auctionMinBidders; // 2 

    mapping(uint256 => ListedToken) private _tokensOnAuction;

    enum AuctionStatus {
        DEFAULT,
        ACTIVE,
        SUCCESSFUL_ENDED,
        UNSUCCESSFULLY_ENDED
    }

    struct AuctionOrder {
        uint256 startPrice;
        uint256 startTime;
        uint256 currentPrice;
        uint256 bidAmount;
        address owner;
        address seller;
        address lastBidder;
        AuctionStatus status;
    }

    struct ListedToken{
        uint256 price;
        address owner;
    }

    constructor(uint256 auctionPeriodMin, uint256 minBidders) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ADMIN_ROLE, _msgSender());
        
        _auctionDuration = auctionPeriodMin;
        _auctionMinBidders = minBidders;
    }

    function createItem(string memory uri) external {
        _totalAmount.increment();
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        nftContract.safeMint(msg.sender, tokenId, uri);
    }

    function listItem(uint256 tokenId, uint256 price) external {
        require(nftContract.ownerOf(tokenId) == msg.sender, "Not an owner of NFT");
        require(price > 0, "Price can't be zero");

        _tokensOnAuction[tokenId].price = price;
        _tokensOnAuction[tokenId].owner = msg.sender;

        nftContract.safeTransferFrom(msg.sender, address(this), tokenId);

        // emit ListedOnAuction
    }

    function buyItem(uint256 tokenId) external {

    }

    function getAuctionDuration() external view returns(uint256) {
        return _auctionDuration;
    }

    function setAuctionDuration(uint256 auctionDuration) external onlyRole(ADMIN_ROLE) {
        _auctionDuration = auctionDuration;
    }

    function getAuctionMinBidders() external view returns(uint256) {
        return _auctionMinBidders;
    }

    function setAuctionMinBidders(uint256 auctionMinBidder) external onlyRole(ADMIN_ROLE) {
        _auctionMinBidders = auctionMinBidder;
    }
    
}
