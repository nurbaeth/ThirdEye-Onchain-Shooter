// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ThirdEyeShooter {
    uint public constant MAP_SIZE = 10;
    uint public playerCount;
    address public owner;

    enum Action { Move, Shoot }
    enum Direction { Up, Down, Left, Right }

    struct Player {
        address addr;
        uint x;
        uint y;
        bool alive;
    }

    mapping(address => Player) public players;
    address[] public playerList;

    modifier onlyAlive() {
        require(players[msg.sender].alive, "You are not alive");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function joinGame(uint x, uint y) external {
        require(playerCount < 10, "Max players");
        require(!players[msg.sender].alive, "Already joined");
        require(x < MAP_SIZE && y < MAP_SIZE, "Invalid position");

        players[msg.sender] = Player(msg.sender, x, y, true);
        playerList.push(msg.sender);
        playerCount++;
    }

    function move(Direction dir) external onlyAlive {
        Player storage p = players[msg.sender];

        if (dir == Direction.Up && p.y > 0) p.y--;
        else if (dir == Direction.Down && p.y < MAP_SIZE - 1) p.y++;
        else if (dir == Direction.Left && p.x > 0) p.x--;
        else if (dir == Direction.Right && p.x < MAP_SIZE - 1) p.x++;
    }

    function shoot(Direction dir) external onlyAlive {
        Player storage shooter = players[msg.sender];

        for (uint i = 0; i < playerList.length; i++) {
            address targetAddr = playerList[i];
            Player storage target = players[targetAddr];

            if (!target.alive || target.addr == msg.sender) continue;

            if (dir == Direction.Up && shooter.x == target.x && target.y < shooter.y) {
                target.alive = false;
                return;
            } else if (dir == Direction.Down && shooter.x == target.x && target.y > shooter.y) {
                target.alive = false;
                return;
            } else if (dir == Direction.Left && shooter.y == target.y && target.x < shooter.x) {
                target.alive = false;
                return;
            } else if (dir == Direction.Right && shooter.y == target.y && target.x > shooter.x) {
                target.alive = false;
                return;
            }
        }
    }

    function getAlivePlayers() external view returns (address[] memory) {
        uint aliveCount = 0;
        for (uint i = 0; i < playerList.length; i++) {
            if (players[playerList[i]].alive) {
                aliveCount++;
            }
        }

        address[] memory alivePlayers = new address[](aliveCount);
        uint idx = 0;
        for (uint i = 0; i < playerList.length; i++) {
            if (players[playerList[i]].alive) {
                alivePlayers[idx++] = playerList[i];
            }
        }
        return alivePlayers;
    }

    function resetGame() external onlyOwner {
        for (uint i = 0; i < playerList.length; i++) {
            delete players[playerList[i]];
        }
        delete playerList;
        playerCount = 0;
    }
}
