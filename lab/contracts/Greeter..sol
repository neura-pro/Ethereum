pragma solidity ^0.4.11;

contract Mortal {
    address owner;

    function Mortal() {
        owner = msg.sender;
    }

    function kill() {
        if (msg.sender == owner) {
            suicide(owner);
        }
    }
}

contract Greeter is Mortal {
    string greeting;

    function Greeter(string _greeting) {
        greeting = _greeting;
    }

    function greet() constant returns (string) {
        return greeting;
    }
}