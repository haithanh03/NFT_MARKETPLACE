// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken {
    mapping (address => uint256) private _balances;
    mapping (address => mapping(address => uint256)) private _allowances;
    uint256 totalSupply = 1000 * 10 ** 18;
    string public name = "NFTMARKET";
    string public symbol = "NM";
    uint public decimals = 18;
    address private ownerToken;

    //event Transfer(address indexed from, address indexed to, uint256 value);
    //event Approval(address indexed owner, address indexed spender, uint256 value);
    constructor() {
        _balances[msg.sender] = totalSupply;
        ownerToken = msg.sender;
    }

    function mint(address to, uint256 amount) public OnlyMint() {
        _balances[to] += amount;
    }

    function balanceOf(address account) public view  returns(uint256){
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual  returns(bool){
        require(balanceOf(msg.sender) >= amount, "invalid amount!");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
       // emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public virtual  view  returns(uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual  returns(bool){
        require(_balances[msg.sender] >= amount, "owner is not enought money to approve!");
        _allowances[msg.sender][spender] = amount;
        //emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual  returns (bool) {
        require(balanceOf(from) >= amount, "You have not enough money!");
        require(allowance(from, msg.sender) >= amount, "is not enough money to transac!");
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
       // emit Transfer(from, to, amount);
        return true;
    }

    modifier OnlyMint{
        require(msg.sender == ownerToken, "You can't mint because you is not a owner!");
        _;
    }
}