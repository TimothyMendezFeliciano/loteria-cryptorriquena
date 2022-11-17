pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";


contract RandomWinnerGame is VRFConsumerBase, Ownable {
    uint256 public fee;
    uint256 public potPrize;
    bytes32 public keyHash;

    mapping(address => string) numberPlayedByAddress;
    address[] public players; // All Active players for next draw
    bool public gameStarted;

    uint256 entryFee;
    uint256 public gameId;

    event GameStarted(uint256 gameId, uint256 entryFee);
    event PlayersJoined(uint256 gameId, address player);
    event GameEnded(uint256 gameId, address winner, bytes requestId, uint256 potPrize);

    constructor(address vrfCoordinator, address linkToken, bytes32 vrfKeyHash, uint256 vrfFee)
    VRFConsumerBase(vrfCoordinator, linkToken) {
        keyHash = vrfKeyHash;
        fee = vrfFee;
        gameStarted = false;
    }

    function startGame(uint256 _entryFee) public onlyOwner {
        require(!gameStarted, "Game is currently running");
        delete players;
        gameStarted = true;
        entryFee = _entryFee; // Use Chainlink Oracle to swap this for ETH/USD based entryFee
        gameId += 1;

        emit GameStarted(gameId, entryFee);
    }

    function joinGame(string _numberPlayedByAddress) public payable {
        require(gameStarted, "Game has not been started yet");
        require(msg.value == entryFee, "Not enough ether sent");

        players.push(msg.sender);
        numberPlayedByAddress[msg.sender] = _numberPlayedByAddress;

        emit PlayersJoined(gameId, msg.sender, numberPlayedByAddress[msg.sender]);
    }

}
