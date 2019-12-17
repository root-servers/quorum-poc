pragma solidity ^0.5.14;

contract Bank {

    // STRUCT
    struct Deal {
        uint256 price;
        bool isOpen;
        bool hasBeenPaid;
    }

    // STATE
    address public archipelContent;
    address public bank;

    mapping(address => Deal) public deals;

    // MODIFIER
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

    modifier dealExist(address dealContract) {
        require(deals[dealContract].isOpen, 'This deal doesn\t exist!');
        _;
    }

    modifier dealDoesntExist(address dealContract) {
        require(!deals[dealContract].isOpen, 'This deal already exist!');
        _;
    }

    // EVENTS
    event NewDeal(address indexed dealContract, uint256 indexed price);
    event DealPaid(address indexed dealContract);
    event DealFinalized(address indexed dealContract);

    // LOGIC
    constructor(address _bank) public {
        archipelContent = msg.sender;
        bank = _bank;
    }

    function createDeal(address dealContract, uint256 price) public onlyArchipel() dealDoesntExist(dealContract) {
        deals[dealContract] = Deal(price, true, false);
        emit NewDeal(dealContract, price);
    }

    function paid(address dealContract) public onlyBank() dealExist(dealContract) {
        deals[dealContract].hasBeenPaid = true;
        emit DealPaid(dealContract);
    }

    function finalize(address dealContract) public onlyArchipel() dealExist(dealContract) {
        deals[dealContract] = Deal(0, false, false);
        emit DealFinalized(dealContract);
    }
}
