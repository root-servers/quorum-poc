pragma solidity ^0.5.14;

contract Distribution {

    // STATE
    address payable public participantA;
    address public participantB;

    uint256 public share; // participant A's share in percent (ex: 10 = 10%, meaning that B get 90%)

    bool public pendingProposition;
    bool public isFromA;
    uint256 public pendingShare;

    // MOIDIFER
    modifier validPercent(uint256 percent) {
        require(percent >= 0, 'Percent cannot be less than 0!');
        require(percent <= 100, 'Percent cannot be more thant 100!');
        _;
    }

    modifier onlyParticipant() {
        require(msg.sender == participantA || msg.sender == participantB, 'Only the participants can call this function!');
        _;
    }

    modifier runningProposition() {
        require(pendingProposition, 'There is no pending proposition !');
        _;
    }

    modifier noRunningProposition() {
        require(!pendingProposition, 'A proposition is pending, please wait until it\'s approved or denied!');
        _;
    }

    modifier notAuthorOfProposition() {
        require( (isFromA && msg.sender != participantA) || (!isFromA && msg.sender != participantB), 'The author of the proposition (you) cannot accept or deny it!');
        _;
    }

    // EVENTS
    event NewProposition(address by, uint256 indexed share);
    event PropositionAccepted(address by, uint256 indexed share);
    event PropositionDenied(address by, uint256 indexed share);
    event PropositionFinalized(address by, uint256 indexed share);

    // LOGIC
    constructor(address _participantB, uint256 initialShare) public validPercent(initialShare) {
        participantA = msg.sender;
        participantB = _participantB;
        share = 101;

        pendingProposition = true;
        isFromA = true;
        pendingShare = initialShare;
        emit NewProposition(msg.sender, initialShare);
    }

    function proposeNewShare(uint256 newShare) public onlyParticipant() noRunningProposition() validPercent(newShare) {
        pendingShare = newShare;
        isFromA = msg.sender == participantA;
        pendingProposition = true;
        emit NewProposition(msg.sender, newShare);
    }

    function accept() public onlyParticipant() runningProposition() notAuthorOfProposition() {
        share = pendingShare;
        pendingShare = 0;
        pendingProposition = false;
        emit PropositionAccepted(msg.sender, share);
    }

    function deny() public onlyParticipant() runningProposition() notAuthorOfProposition() {
        pendingShare = 0;
        pendingProposition = false;
        emit PropositionDenied(msg.sender, share);
    }

    function finalize() public noRunningProposition() {
        emit PropositionFinalized(msg.sender, share); // emit before selfdestruct
        selfdestruct(participantA);
    }
}
