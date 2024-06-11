//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyTokenNFT is ERC721URIStorage, Ownable 
{
    constructor() ERC721("MarketNFT", "MNFT") {}

    function mint(address _to, uint256 _tokenID, string calldata _uri) external onlyOwner {
        _mint(_to, _tokenID);
        _setTokenURI(_tokenID, _uri);
    }

    function transferTo(uint256 tokenid, address to) public virtual returns(bool) 
    {
        require(ownerOf(tokenid) == msg.sender, "You are not owner of tokenid");
        _safeTransfer(msg.sender, to, tokenid, bytes(""));
        emit Transfer(msg.sender, to, tokenid);
        return true;
    }
    
    function approvalTo(address to, uint256 tokenid) public virtual returns(bool)
    {
        require(ownerOf(tokenid) == msg.sender, "You have not nft to approval!");
        approve(to, tokenid);
        return true;
    }

    function transferFromTo(uint256 tokenid, address from, address to) public virtual  returns(bool)
    {
        require(_isApprovedOrOwner(msg.sender, tokenid) == true, "NFT has not been approved!");
        _safeTransfer(from, to, tokenid,"");
        return true;
    }
    
}