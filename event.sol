// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract EventFactory is Ownable {
    event EventCreated(address indexed eventContract, string eventName, string tokenName, uint256 maxCapacity, uint256 eventDate);

    function createEvent(
        string memory eventName,
        string memory tokenName,
        uint256 maxCapacity,
        uint256 eventDate
    ) external onlyOwner {
        Event newEvent = new Event(eventName, tokenName, maxCapacity, eventDate);
        emit EventCreated(address(newEvent), eventName, tokenName, maxCapacity, eventDate);
    }
}

contract Event is Ownable, ERC721 {
    struct Ticket {
        address eventContract;
        address owner;
        uint256 ticketId;
    }

    string public eventName;
    string public tokenName;
    uint256 public maxCapacity;
    uint256 public currentCapacity;
    uint256 public eventDate;

    mapping(address => bool) private _hasPurchasedTicket;
    mapping(uint256 => Ticket) private _tickets;
    uint256 private _ticketCounter;

    constructor(
        string memory _eventName,
        string memory _tokenName,
        uint256 _maxCapacity,
        uint256 _eventDate
    ) ERC721(_tokenName, "ET") {
        eventName = _eventName;
        tokenName = _tokenName;
        maxCapacity = _maxCapacity;
        currentCapacity = _maxCapacity;
        _ticketCounter = 0;
        eventDate = _eventDate;
    }

    function buyTicket() external {
        require(currentCapacity > 0, "Event is already at maximum capacity");
        require(!_hasPurchasedTicket[msg.sender], "You have already purchased a ticket");

        _ticketCounter++;
        uint256 ticketId = _ticketCounter;
        _safeMint(msg.sender, ticketId);

        Ticket memory newTicket = Ticket({
            eventContract: address(this),
            owner: msg.sender,
            ticketId: ticketId
        });
        _tickets[ticketId] = newTicket;
        _hasPurchasedTicket[msg.sender] = true;

        currentCapacity--;
    }

    function getTicketOwner(uint256 ticketId) external view returns (address) {
        require(_exists(ticketId), "Ticket does not exist");

        return ownerOf(ticketId);
    }

    function getEventDetails() external view returns (string memory, string memory, uint256, uint256, uint256) {
        return (eventName, tokenName, maxCapacity, currentCapacity, eventDate);
    }

    // Override transfer functions to prevent transfers
    function transferFrom(
        address /* from */,
        address /* to */,
        uint256 /* tokenId */
    ) public pure override {
        revert("Event Ticket: Transfers are not allowed");
    }

    function safeTransferFrom(
        address /* from */,
        address /* to */,
        uint256 /* tokenId */
    ) public pure override {
        revert("Event Ticket: Transfers are not allowed");
    }

    function safeTransferFrom(
        address /* from */,
        address /* to */,
        uint256 /* tokenId */,
        bytes memory /* _data */
    ) public pure override {
        revert("Event Ticket: Transfers are not allowed");
    }

    function burnTicket(uint256 ticketId) external {
        require(_exists(ticketId), "Ticket does not exist");

        address owner = ownerOf(ticketId);
        require(owner == msg.sender, "You are not the owner of this ticket");

        _burn(ticketId);
        delete _tickets[ticketId];
   delete _hasPurchasedTicket[owner];

    currentCapacity++;
}
}