
pragma solidity ^0.5.14;

//import './member-registry.sol';

contract Movie {

    // STRUCTS ---------------------------------------------

    struct Deal {
        address a;
        uint8 shareA;
        address b;
        uint8 shareB;
        uint256 timestamp;
    }

    // STATE ---------------------------------------------

    address[] membersOfDeals;
    mapping(address => bool) isPartOfADeal;
    mapping(address => uint8) finalShare;

    mapping(bytes32 => Deal) pendingDeals;
    uint256 pendingDealsCount;
    mapping(bytes32 => Deal) acceptedDeals;
    uint256 acceptedDealsCount;

    // MODIFIERS ---------------------------------------------

    modifier canPropose() {
        if (acceptedDealsCount > 0) {
            require(isPartOfADeal[msg.sender], 'Only member of a previous deal can create a new deal!');
        }
        _;
    }

    modifier validShare(uint8 shareB) {
        require(shareB >= 0, 'A share cannot be less than 0%!');
        require(shareB <= 100, 'A share cannot be more than 100%!');
        _;
    }
    modifier dealIsPending(bytes32 dealId) {
        Deal memory pending = pendingDeals[dealId];
        require(pending.timestamp != 0, 'This deals is not pending!');
        _;
    }
    modifier dealIsAccepted(bytes32 dealId) {
        Deal memory accepted = acceptedDeals[dealId];
        require(accepted.timestamp != 0, 'This deals is already accepted!');
        _;
    }
    modifier dealIsNotAccepted(bytes32 dealId) {
        Deal memory accepted = acceptedDeals[dealId];
        require(accepted.timestamp == 0, 'This deals is already accepted!');
        _;
    }
    modifier onlyB(bytes32 dealId) {
        Deal memory pending = pendingDeals[dealId];
        require(msg.sender == pending.b, 'Only Participant B can perform this action!');
        _;
    }

    // EVENTS ---------------------------------------------

    event NewPendingDeal(bytes32 indexed dealId, address indexed a, address indexed b);
    event DealAccepted(bytes32 indexed dealId, address indexed a, address indexed b);
    event DealDenied(bytes32 indexed dealId, address indexed a, address indexed b);
    event NewPayment(address member, uint256 amount);

    event Debug(address indexed member, uint256 indexed finalShare); // TODO REMOVE THAT !!!!!!!!!!!

    // FUNCTIONS ---------------------------------------------

    constructor() public {
        pendingDealsCount = 0;
        acceptedDealsCount = 0;
    }

    function addDeal(address b, uint8 shareB) public
        canPropose
        validShare(shareB)
        returns(bytes32)
    {
        pendingDealsCount++;
        uint8 shareA = 100 - shareB;
        bytes32 dealId = keccak256(abi.encodePacked(msg.sender, shareA, b, shareB, now));
        pendingDeals[dealId] = Deal(msg.sender, shareA, b, shareB, now);
        emit NewPendingDeal(dealId, msg.sender, b);
        return dealId;
    }

    function acceptDeal(bytes32 dealId) public dealIsPending(dealId) dealIsNotAccepted(dealId) onlyB(dealId) returns(bytes32) {
        Deal memory pending = pendingDeals[dealId];
        resetPendingDeal(dealId);

        acceptedDealsCount++;
        bytes32 acceptedId = keccak256(abi.encodePacked(pending.a, pending.shareA, pending.b, pending.shareB, now));
        acceptedDeals[acceptedId] = Deal(pending.a, pending.shareA, pending.b, pending.shareB, now);

        if (acceptedDealsCount == 1) {
            finalShare[pending.a] = pending.shareA;
            finalShare[pending.b] = pending.shareB;
        } else {
            finalShare[pending.a] = (finalShare[pending.a] * pending.shareA) / 100;
            finalShare[pending.b] += (finalShare[pending.a] * pending.shareB) / 100;
        }

        emit Debug(pending.a, finalShare[pending.a]);
        emit Debug(pending.b, finalShare[pending.b]);

        if (!isPartOfADeal[pending.a]) {
            membersOfDeals.push(pending.a);
        }
        if (!isPartOfADeal[pending.b]) {
            membersOfDeals.push(pending.b);
        }
        isPartOfADeal[pending.a] = true;
        isPartOfADeal[pending.b] = true;

        //updateShare(pending.a, pending.shareA);
        //updateShare(pending.b, pending.shareB);

        //if (!areTotalSharesCorrect()) {
        //    revert('Sum of percent does not add up to 100%!');
        //}

        emit DealAccepted(acceptedId, pending.a, pending.b);
        return acceptedId;
    }

    function denyDeal(bytes32 dealId) public dealIsPending(dealId) onlyB(dealId) {
        Deal memory penidng = pendingDeals[dealId];
        resetPendingDeal(dealId);
        emit DealDenied(dealId, penidng.a, penidng.b);
    }

    function pay(uint256 price) public {
        for(uint256 i = 0 ; i < membersOfDeals.length ; i++) {
            address member = membersOfDeals[i];
            uint8 share = finalShare[member];
            uint256 amount = (price * share) / 100;
            emit NewPayment(member, amount);
        }
    }

    // PRIVATE ---------------------------------------------

    function resetPendingDeal(bytes32 dealId) private dealIsPending(dealId) {
        pendingDeals[dealId] = Deal(address(0), 0, address(0), 0, 0);
        pendingDealsCount--;
    }
    function updateShare(address member, uint8 newShare) private {
        if (isPartOfADeal[member]) {
            uint8 oldShare = finalShare[member];
            finalShare[member] = (oldShare * newShare) / 100;
        } else {
            membersOfDeals.push(member);
            finalShare[member] = newShare;
        }
        isPartOfADeal[member] = true;
    }
    function areTotalSharesCorrect() public view returns(bool) {
        uint256 total = 0;
        for(uint256 i = 0 ; i < membersOfDeals.length ; i++) {
            address member = membersOfDeals[i];
            total += finalShare[member];
        }
        if (total == 100) {
            return true;
        }
        return false;
    }

    // GETTERS ---------------------------------------------

    function isMemberPartOfADeals(address member) public view returns(bool) {
        return isPartOfADeal[member];
    }
    function getMembersOfDeals() public view returns(address[] memory) {
        return membersOfDeals;
    }
    function getFinalShare(address member) public view returns(uint256) {
        return finalShare[member];
    }
    function getPendingDeal(bytes32 dealId) public view returns(address, uint8, address, uint8, uint256) {
        Deal memory pending = pendingDeals[dealId];
        return (pending.a, pending.shareA, pending.b, pending.shareB, pending.timestamp);
    }
    function getPendingDealCount() public view returns(uint256) {
        return pendingDealsCount;
    }
    function getAcceptedDeal(bytes32 dealId) public view returns(address, uint8, address, uint8, uint256) {
        Deal memory accepted = acceptedDeals[dealId];
        return (accepted.a, accepted.shareA, accepted.b, accepted.shareB, accepted.timestamp);
    }
    function getAcceptedDealCount() public view returns(uint256) {
        return acceptedDealsCount;
    }
}
