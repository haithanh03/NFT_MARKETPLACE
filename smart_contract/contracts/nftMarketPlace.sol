//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;
//import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "marketplace/Erc20.sol";
//import "marketplace/Erc721.sol";

contract Marketplace is IERC721Receiver, IERC1155Receiver, Ownable {
    using Counters for Counters.Counter;
    //Counters.Counter private _tokenIds;
    //Counters.Counter private _itemsSold;
    address marketplaceOwner;
    IERC721 nft721;
    IERC20 erc20Token;
    IERC1155 nft1155;
    uint256 listPrice = 0.01 ether;
    uint256 public transactionFee;
    mapping(address => mapping(uint256 => bool)) private _balances;
    mapping(address => mapping(address => uint256)) private _allowance;

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256("onERC1155Received(address,address,uint256,bytes)")
            );
    }

    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],bytes)"
                )
            );
    }

    function supportsInterface(bytes4 interfaceId)
        external
        view
        override
        returns (bool)
    {}

   
    event AuctionEnded(
        uint256 tokenId,
        address owner,
        address highestBidder,
        uint256 highestBid
    );
    event OfferMade(
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 offerAmount,
        uint256 priceOffer
    );
    event OfferAccepted(
        uint256 indexed tokenId,
        address indexed seller,
        address indexed buyer,
        uint256 offerAmount,
        uint256 priceOffer
    );

    //event ERC20Purchase(uint256 indexed tokenId, address indexed seller, address indexed buyer, uint256 tokenAmount, address erc20Token);
    constructor(
        address _erc20,
        address _erc721,
        address _erc1155
    ) {
        marketplaceOwner = msg.sender;
        nft721 = IERC721(_erc721);
        erc20Token = IERC20(_erc20);
        nft1155 = IERC1155(_erc1155);
    }

    struct ListedToken {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        uint256 amount;
        bool currentlyListed;
        //mapping(address => uint256) offers;
    }

    struct Offer {
        uint256 tokenId;
        address offer;
        uint256 amount;
        uint256 priceOffer;
        bool accepted;
    }
    //mapping(uint256 => Offer[]) public tokenOffers;
    event TokenListedSuccess(
        uint256 indexed tokenId,
        address owner,
        address seller,
        uint256 price,
        bool currentlyListed
    );
    //event Transfer(address indexed from, address indexed to, uint256 tokenid);
    //event Approval(address indexed owner, address indexed spender, uint256 tokenid);
    event TokenListed(
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price
    );
    event TokenSold(
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price
    );
    event OfferMade(
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 offerAmount
    );
    event OfferAccepted(
        uint256 indexed tokenId,
        address indexed seller,
        address indexed buyer,
        uint256 offerAmount
    );
    event ERC20Purchase(
        uint256 indexed tokenId,
        address indexed seller,
        address indexed buyer,
        uint256 tokenAmount,
        address erc20Token
    );
    event AuctionStarted(
        uint256 indexed tokenId,
        address indexed owner,
        uint256 start,
        uint256 finish,
        uint256 startingPrice,
        uint256 minstep
    );

    event AuctionFinished(
        uint256 indexed tokenId,
        address indexed winner,
        address indexed owner,
        uint256 price
    );

    event AuctionJoined(
    uint256 indexed tokenId,
    address indexed bidder,
    uint256 amount
);
    mapping(uint256 => ListedToken) public listedTokens721;
    mapping(uint256 => mapping(address => ListedToken)) public listedTokens1155;

    mapping(uint256 => Offer[]) public Offer721;
    mapping(uint256 => mapping(address => Offer[])) public Offer1155;

    mapping(uint256 => Auction) public Auction721;
    mapping(uint256 => mapping(address => Auction)) public Auction1155;


    /*constructor() ERC721("NFTMarketplace", "NFTM") {
        marketplaceOwner = payable(msg.sender);
    }*/

    /*modifier onlyOwner ()
    {
        require(msg.sender == marketplaceOwner, "You are not owner of marketplace!");
        _;
    }*/

    function TransferOwnership(address Newowner) external onlyOwner {
        require(Newowner != address(0), "Invalid address!");
        marketplaceOwner = Newowner;
    }

    function updateListPrice(uint256 _listPrice) public payable onlyOwner {
        listPrice = _listPrice;
    }

    function isERC1155(address _contractAddress) internal view returns (bool) {
        bytes4 interfaceId = type(IERC1155Receiver).interfaceId;
        (bool success, bytes memory result) = _contractAddress.staticcall(
            abi.encodeWithSelector(
                IERC165.supportsInterface.selector,
                interfaceId
            )
        );
        return success && (result.length > 0 && abi.decode(result, (bool)));
    }

    /*function checkNFT(uint256 _tokenId, uint256 _amount) private view returns(bool)
    {
        ListedToken storage token = listedTokens[_tokenId];
        if(_amount > 1) return true;
        else
        {
            if((address)_tokenId == (address)nft721) return false;
            return true;
        }
    }*/

function buy721(uint256 _tokenId, uint256 _amount) external {
    ListedToken storage token = listedTokens721[_tokenId];
    
    require(token.currentlyListed, "Token not listed");
    require(
        erc20Token.allowance(msg.sender, address(this)) >= token.price * _amount,
        "Insufficient allowance"
    );
    require(
        erc20Token.balanceOf(msg.sender) >= token.price * _amount,
        "Insufficient balance"
    );

    // Transfer ERC721 token from the marketplace to the buyer
    nft721.safeTransferFrom(address(this), msg.sender, _tokenId);

    // Transfer payment from buyer to seller
    erc20Token.transferFrom(msg.sender, token.owner, token.price * _amount);

    // Update token listing
    token.amount -= _amount;
    if (token.amount == 0) {
        token.currentlyListed = false;
    }

    emit TokenSold(_tokenId, msg.sender, token.price * _amount);
}

function sell721(uint256 _tokenId, uint256 _price, uint256 _amount) external {
    require(!listedTokens721[_tokenId].currentlyListed, "Token already listed");
    require(_amount > 0, "Invalid amount");
    require(nft721.ownerOf(_tokenId) == msg.sender, "You don't own this token");

    // Transfer ERC721 token from seller to the marketplace
    nft721.safeTransferFrom(msg.sender, address(this), _tokenId);

    // Update token listing
    listedTokens721[_tokenId] = ListedToken({
        tokenId: _tokenId,
        owner: payable(msg.sender),
        seller: payable(msg.sender),
        price: _price,
        amount: _amount,
        currentlyListed: true
    });

    emit TokenListed(_tokenId, msg.sender, _price);
}

function buy1155(uint256 _tokenId, uint256 _amount) external {
    ListedToken storage token = listedTokens1155[_tokenId][msg.sender];
    
    require(token.currentlyListed, "Token not listed");
    require(
        erc20Token.allowance(msg.sender, address(this)) >= token.price * _amount,
        "Insufficient allowance"
    );
    require(
        erc20Token.balanceOf(msg.sender) >= token.price * _amount,
        "Insufficient balance"
    );

    // Transfer ERC1155 token from the marketplace to the buyer
    nft1155.safeTransferFrom(address(this), msg.sender, _tokenId, _amount, "");

    // Transfer payment from buyer to seller
    erc20Token.transferFrom(msg.sender, token.owner, token.price * _amount);

    // Update token listing
    token.amount -= _amount;
    if (token.amount == 0) {
        token.currentlyListed = false;
    }

    emit TokenSold(_tokenId, msg.sender, token.price * _amount);
}

function sell1155(uint256 _tokenId, uint256 _price, uint256 _amount) external {
    require(!listedTokens1155[_tokenId][msg.sender].currentlyListed, "Token already listed");
    require(_amount > 0, "Invalid amount");
    require(nft1155.balanceOf(msg.sender, _tokenId) >= _amount, "Insufficient balance");

    // Transfer ERC1155 token from seller to the marketplace
    nft1155.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "");

    // Update token listing
    listedTokens1155[_tokenId][msg.sender] = ListedToken({
        tokenId: _tokenId,
        owner: payable(msg.sender),
        seller: payable(msg.sender),
        price: _price,
        amount: _amount,
        currentlyListed: true
    });

    emit TokenListed(_tokenId, msg.sender, _price);
}


    // ERC20 purchase function can be implemented similarly to the buy function

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // Withdraw ERC20 tokens sent to this contract
    function withdrawERC20(address _tokenContract) external onlyOwner {
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(owner(), balance), "Transfer failed");
    }

    
function makeOffer721(
    uint256 _tokenId,
    uint256 _amount,
    uint256 _priceOffer
) external {
    require(listedTokens721[_tokenId].currentlyListed, "Token not listed");
    require(_amount > 0, "Offer amount must be greater than zero");

    Offer[] storage tokenOffers = Offer721[_tokenId];
    tokenOffers.push(Offer({
        tokenId: _tokenId,
        offer: msg.sender,
        amount: _amount,
        priceOffer: _priceOffer,
        accepted: false
    }));

    emit OfferMade(_tokenId, msg.sender, _amount, _priceOffer);
}

function acceptOffer721(uint256 _tokenId, uint256 _index) external {
    Offer[] storage tokenOffers = Offer721[_tokenId];

    require(
        _index < tokenOffers.length,
        "Invalid offer index"
    );

    Offer storage offer = tokenOffers[_index];
    require(
        !offer.accepted,
        "Offer already accepted"
    );

    require(
        nft721.ownerOf(_tokenId) == msg.sender,
        "You don't own this token"
    );

    // Additional checks can be added here, such as verifying the offer amount against the listed price.

    if (offer.amount > 1) {
        require(
            isERC1155(address(nft1155)),
            "Contract does not support ERC1155"
        );
        nft1155.safeTransferFrom(
            msg.sender,
            offer.offer,
            _tokenId,
            offer.amount,
            ""
        );
    } else {
        nft721.safeTransferFrom(msg.sender, offer.offer, _tokenId);
    }

    erc20Token.transferFrom(offer.offer, msg.sender, offer.priceOffer);

    offer.accepted = true;

    emit OfferAccepted(
        _tokenId,
        msg.sender,
        offer.offer,
        offer.amount,
        offer.priceOffer
    );
}

function makeOffer1155(
    uint256 _tokenId,
    uint256 _amount,
    uint256 _priceOffer
) external {
    require(listedTokens1155[_tokenId][msg.sender].currentlyListed, "Token not listed");
    require(_amount > 0, "Offer amount must be greater than zero");

    Offer[] storage tokenOffers = Offer1155[_tokenId][msg.sender];
    tokenOffers.push(Offer({
        tokenId: _tokenId,
        offer: msg.sender,
        amount: _amount,
        priceOffer: _priceOffer,
        accepted: false
    }));

    emit OfferMade(_tokenId, msg.sender, _amount, _priceOffer);
}

function acceptOffer1155(uint256 _tokenId, uint256 _index) external {
    Offer[] storage tokenOffers = Offer1155[_tokenId][msg.sender];

    require(
        _index < tokenOffers.length,
        "Invalid offer index"
    );

    Offer storage offer = tokenOffers[_index];
    require(
        !offer.accepted,
        "Offer already accepted"
    );

    require(
        nft1155.balanceOf(msg.sender, _tokenId) >= offer.amount,
        "You don't have enough tokens"
    );

    // Additional checks can be added here, such as verifying the offer amount against the listed price.

    nft1155.safeTransferFrom(
        msg.sender,
        offer.offer,
        _tokenId,
        offer.amount,
        ""
    );

    erc20Token.transferFrom(offer.offer, msg.sender, offer.priceOffer);

    offer.accepted = true;

    emit OfferAccepted(
        _tokenId,
        msg.sender,
        offer.offer,
        offer.amount,
        offer.priceOffer
    );
}

    struct Auction {
        uint256 tokenid;
        address payable owner;
        uint256 start;
        uint256 finish;
        uint256 startingPrice;
        uint256 actualPrice;
        uint256 minstep;
        bool state;
        address payable highest;
    }
    //mapping(address => mapping(uint256 => Auction)) public auction;
    function startAuction721(
        uint256 _tokenId,
        uint256 _start,
        uint256 _finish,
        uint256 _startingPrice,
        uint256 _minstep
    ) external {
        require(!Auction721[_tokenId].state, "Auction already started");
        require(nft721.ownerOf(_tokenId) == msg.sender, "You don't own this token");
        require(_start < _finish, "Invalid auction duration");

        nft721.safeTransferFrom(msg.sender, address(this), _tokenId);

        Auction721[_tokenId] = Auction({
            tokenid: _tokenId,
            owner: payable(msg.sender),
            start: _start,
            finish: _finish,
            startingPrice: _startingPrice,
            actualPrice: _startingPrice,
            minstep: _minstep,
            state: true,
            highest: payable(address(0))
        });

        emit AuctionStarted(_tokenId, msg.sender, _start, _finish, _startingPrice, _minstep);
    }

    function placeBidERC20(uint256 _tokenId, uint256 _bidAmount) external {
        Auction storage auction = Auction721[_tokenId];
        require(auction.state, "Auction not started");
        require(block.timestamp >= auction.start && block.timestamp <= auction.finish, "Auction not active");
        require(_bidAmount > auction.actualPrice, "Bid must be higher than current price");
        require(msg.sender != auction.highest, "You are already the highest bidder");

        uint256 difference = _bidAmount - auction.actualPrice;
        require(difference >= auction.minstep, "Bid increment too low");

        erc20Token.transferFrom(msg.sender, address(this), _bidAmount);
        if (auction.highest != address(0)) {
            erc20Token.transfer(auction.highest, auction.actualPrice); // Refund the previous highest bidder
        }
        auction.actualPrice = _bidAmount;
        auction.highest = payable(msg.sender);

        emit AuctionEnded(_tokenId, auction.owner, msg.sender, _bidAmount);
    }

    function endAuction721(uint256 _tokenId) external {
        Auction memory auction = Auction721[_tokenId];
        require(auction.state, "Auction not started");
        require(block.timestamp > auction.finish, "Auction not ended yet");

        nft721.safeTransferFrom(address(this), auction.highest, _tokenId);
        erc20Token.transfer(auction.owner, auction.actualPrice);

        emit AuctionEnded(_tokenId, auction.owner, auction.highest, auction.actualPrice);

        delete Auction721[_tokenId];
    }
}





