pragma solidity ^0.4.11;

import "./Token.sol";

contract Crowdsale {
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    Token public token;
    Funder[] public funders;

    event FundTransfer(address backer, uint amount, bool isContribution);

    struct Funder {
        address addr;
        uint amount;
    }

    function Crowdsale(uint _fundingGoal, uint _duration, uint _price, uint _reward) {
        beneficiary = msg.sender;
        fundingGoal = _fundingGoal;
        deadline = now + _duration * 1 minutes;
        price = _price;
        token = new Token(_reward);
    }

    function contribute() payable {
        uint amount = msg.value;
        funders.push(Funder({
            addr: msg.sender,
            amount: amount
        }));
        amountRaised += amount;
        token.sendCoin(msg.sender, amount * price);
        FundTransfer(msg.sender, amount, true);
    }

    function getTokenBalance(address addr) constant returns(uint) {
        return token.getBalance(addr);
    }

    modifier afterDeadline() {
        if (now >= deadline) {
            _;
        }
    }

    function checkGoalReached() afterDeadline {
        if (amountRaised >= fundingGoal) {
            beneficiary.transfer(amountRaised);
            FundTransfer(beneficiary, amountRaised, false);
        } else {
            //FundTransfer(0, 11, false);
            for (uint i = 0; i < funders.length; i++) {
              funders[i].addr.transfer(funders[i].amount);  
              FundTransfer(funders[i].addr, funders[i].amount, false);
            }               
        }
        suicide(beneficiary);
    }

}