pragma solidity ^0.5.14;

import './distribution.sol';

contract Bank {

    struct Movie {
        string name;
        uint256 price;
        bool hasBeenPaid;
        Distribution[] deals;
    }

    // STATE
    address public archipelContent;
    address public bank;
    uint256 public movieCount;
    mapping(uint256 => Movie) public movies;

    // MODIFIERS
    modifier onlyArchipel() {
        require(msg.sender == archipelContent, 'Only Archipel-Content can trigger this function!');
        _;
    }

    modifier onlyBank() {
        require(msg.sender == bank, 'Only Bank can trigger this function!');
        _;
    }

    modifier onlyArchipelOrBank() {
        require(msg.sender == archipelContent || msg.sender == bank, 'Only Archipel-Content or Bank can trigger this function!');
        _;
    }

    modifier movieExist(uint256 id) {
        bytes32 emptyString = keccak256(abi.encodePacked(''));
        bytes32 movieName = keccak256(abi.encodePacked(movies[id].name));
        require(movieName != emptyString, 'There is no movie with this id!');
        _;
    }

    modifier movieNotAlreadyPaid(uint256 id) {
        require(!movies[id].hasBeenPaid, 'This movie is already paid!');
        _;
    }

    modifier allDealsAreFinal(uint256 id) {
        bool allFinals = true;
        Distribution[] memory deals = movies[id].deals;
        for(uint256 i = 0 ; i < deals.length ; i++) {
            bool currentFinal = deals[i].getFinalized(); // for some reason (maybe byzantuium) the compiler will not let me direclty acces the public value
            if (!currentFinal) {
                allFinals = false;
                break;
            }
        }
        require(allFinals, 'One or more deal(s) is/are not finalized yet!');
        _;
    }

    // EVENTS
    event NewMovie(uint256 indexed movieId, uint256 indexed price, string name);
    event NewDeal(uint256 indexed movieId, address indexed participant, address indexed dealContract);
    event MoviePaid(uint256 indexed movieId);
    event Pay(uint256 indexed movieId, address indexed participant, uint256 indexed amount);

    // LOGIC
    constructor(address _bank) public {
        archipelContent = msg.sender;
        bank = _bank;
        movieCount = 0;
    }

    function createMovie(string memory _name, uint256 _price) public onlyArchipel() returns(uint256) {
        uint256 newId = movieCount;
        movieCount++;
        movies[newId] = Movie(_name, _price, false, new Distribution[](0));
        emit NewMovie(newId, _price, _name);
        return newId;
    }

    function addDealToMovie(uint256 movieId, address participant) public onlyArchipel() movieExist(movieId) returns(Distribution) {
        Distribution deal = new Distribution(msg.sender, participant, 10); // inital share is 10% for Archipel-Content (participant A = msg.sender) & 90% for the other participant (B = the one in this function parameter)
        movies[movieId].deals.push(deal);
        emit NewDeal(movieId, participant, deal);
        return deal;
    }

    function canBePaid(uint256 movieId) public view movieExist(movieId) movieNotAlreadyPaid(movieId) allDealsAreFinal(movieId) returns(bool){
        return true;
    }
    function moviePaid(uint256 movieId) public onlyBank() movieExist(movieId) movieNotAlreadyPaid(movieId) allDealsAreFinal(movieId) {
        movies[movieId].hasBeenPaid = true;
        Distribution[] memory deals = movies[movieId].deals;
        uint256 price = movies[movieId].price;

        uint256 archipelShare = 0;
        uint256[] memory participantShares = new uint256[](deals.length);
        address[] memory participantAddresses = new address[](deals.length);

        // ! WARNING : HERE WE ASSUME THAT EVERY PERCENTAGE ARE COHERENT AND WE DO NOT CHECK ANYTHING
        // every participant could have claim 100% of the price in wich case the total will bemore thant the actual price

        for(uint256 i = 0 ; i < deals.length ; i++) {
            participantAddresses[i] = deals[i].getParticipant();
            uint256 amount = (deals[i].getShare() * price) / 100;
            participantShares[i] = (100 - amount);
            archipelShare += deals[i].getShare();
        }

        emit MoviePaid(movieId);
        emit Pay(movieId, archipelContent, archipelShare);
        for(uint256 i = 0 ; i < deals.length ; i++) {
            emit Pay(movieId, participantAddresses[i], participantShares[i]);
        }
    }
}
