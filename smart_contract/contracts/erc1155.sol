//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc1155 is ERC1155, Ownable{
    constructor() ERC1155("ERC1155"){}
    function mint(address owner, uint256 id, uint256 quantity, bytes memory data, string calldata _uri) external onlyOwner
    {
        _mint(owner, id, quantity, data);
        _setURI(_uri);
    }
}