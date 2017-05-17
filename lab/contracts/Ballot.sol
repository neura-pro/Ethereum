pragma solidity ^0.4.11;

contract Ballot {

    struct Voter {
        uint weight;
        bool voted;
        address proxy;
        uint vote;
    }

    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    address owner;
    mapping (address => Voter) voters;
    Proposal[] proposals;

    /*function Ballot(bytes32[] proposalNames) {
        owner = msg.sender;
        voters[owner].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }*/

    function Ballot() {
        owner = msg.sender;
        voters[owner].weight = 1;
    }

    function addProposal(string name) {
        proposals.push(Proposal({
            name: sha3(name),
            voteCount: 0
        }));
    }
    function getProposalName(uint id) constant returns (bytes32) {
        return proposals[id].name;
    }
    function getProposalVoteCount(uint id) constant returns (uint) {
        return proposals[id].voteCount;
    }

    function addVoter(address voter) {
        require((msg.sender == owner) && !voters[voter].voted);
        voters[voter].weight = 1;
    }
    function getVoterWeight(address voter) constant returns (uint) {
        return voters[voter].weight;
    }

    function assignProxy(address proxy) {
        
        Voter voter = voters[msg.sender];
        require(!voter.voted);
        
        require(proxy != msg.sender);
        while (voters[proxy].proxy != address(0)) {
            proxy = voters[proxy].proxy;
            require(proxy != msg.sender);
        }

        voter.voted = true;
        voter.proxy = proxy;

        Voter proxyVoter = voters[proxy];
        proxyVoter.weight += voter.weight;
        if (proxyVoter.voted) {
            proposals[proxyVoter.vote].voteCount += voter.weight;
        }
    }

    function vote(uint proposalId) {
        Voter voter = voters[msg.sender];
        require((voter.weight) > 0 && !voter.voted);

        voter.voted = true;
        voter.vote = proposalId;

        proposals[proposalId].voteCount += voter.weight;
    }

    function getWinningProposalId() constant returns (uint winningProposalId) {
        uint winningVoteCount  = 0;
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount ) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalId = i;
            }
        }
    }

    function getWinningProposalName() constant returns (bytes32) {
        return proposals[getWinningProposalId()].name;
    }
}