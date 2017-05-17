pragma solidity ^0.4.11;

contract Token { 
    mapping (address => uint) public balance;
    event CoinTransfer(address sender, address receiver, uint amount);
    
    function Token(uint supply) {
        balance[msg.sender] = supply;
    }

    function getBalance(address addr) constant returns(uint) {
        return balance[addr];
    }

    function sendCoin(address receiver, uint amount) returns(bool sufficient) {
        if (balance[msg.sender] < amount) {
            return false;
        }
        balance[msg.sender] -= amount;
        balance[receiver] += amount;
        CoinTransfer(msg.sender, receiver, amount);
        return true;
    }
}