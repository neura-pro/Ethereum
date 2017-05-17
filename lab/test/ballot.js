var Ballot = artifacts.require("./Ballot.sol");

contract('Ballot', function(accounts) {
    it("add proposals", function(done) {
        var inst;

        Ballot.deployed().then(function(instance) {
            inst = instance;
        }).then(function() {
            return inst.addProposal("uno");
        }).then(function() {
            return inst.getProposalName.call(0);
        }).then(function(value) {
            assert.equal(value, web3.sha3("uno"), "proposal[0] name");
        }).then(function() {
            return inst.getProposalVoteCount.call(0);
        }).then(function(value) {
            assert.equal(value.toNumber(), 0, "proposal[0] vote count before vote");
        }).then(function() {
            return inst.addProposal("alt");
        }).then(function() {
            return inst.getProposalName.call(1);
        }).then(function(value) {
            assert.equal(value, web3.sha3("alt"), "proposal[1] name");
        }).then(function() {
            return inst.getProposalVoteCount.call(1);
        }).then(function(value) {
            assert.equal(value.toNumber(), 0, "proposal[1] vote count before vote");
        }).then(done).catch(done);
    });

    it("register voters", function(done) {
        var inst;

        Ballot.deployed().then(function(instance) {
            inst = instance;
        }).then(function() {
            return inst.getVoterWeight.call(accounts[0]);
        }).then(function(value) {
            assert.equal(value.toNumber(), 1, "account[0] weight");
        }).then(function() {
            return inst.addVoter(accounts[1]);
        }).then(function() {
            return inst.getVoterWeight.call(accounts[1]);
        }).then(function(value) {
            assert.equal(value.toNumber(), 1, "account[1] weight");
        }).then(function() {
            return inst.addVoter(accounts[2]);
        }).then(function() {
            return inst.getVoterWeight.call(accounts[2]);
        }).then(function(value) {
            assert.equal(value.toNumber(), 1, "account[2] weight");
        }).then(done).catch(done);
    });

    it("assign proxy", function(done) {
        var inst;

        Ballot.deployed().then(function(instance) {
            inst = instance;
        }).then(function() {
            return inst.addVoter(accounts[8]);
        }).then(function() {
            return inst.getVoterWeight.call(accounts[8]);
        }).then(function(value) {
            assert.equal(value.toNumber(), 1, "account[8] weight before proxy");
        }).then(function() {
            return inst.assignProxy(accounts[8], {from: accounts[0]});
        }).then(function() {
            return inst.assignProxy(accounts[8], {from: accounts[0]});}).then(function() {throw new Error();
        }).catch(function(err) {
            assert(err.toString().indexOf('invalid opcode') != -1, "no error thrown when double proxy assigment");
        }).then(function() {
            return inst.assignProxy(accounts[8], {from: accounts[1]});
        }).then(function() {
            return inst.getVoterWeight.call(accounts[8]);
        }).then(function(value) {
            assert.equal(value.toNumber(), 3, "account[8] weight after proxy");
        }).then(done).catch(done);
    });

    it("actual vote", function(done) {
        var inst;

        Ballot.deployed().then(function(instance) {
            inst = instance;
        }).then(function() {
            return inst.vote(0, {from: accounts[0]});}).then(function() {throw new Error();
        }).catch(function(err) {
            assert(err.toString().indexOf('invalid opcode') != -1, "no error thrown when vote after proxy assignment");
        }).then(function() {
            return inst.vote(0, {from: accounts[2]});
        }).then(function() {
            return inst.vote(1, {from: accounts[8]});
        }).then(function() {
            return inst.vote(1, {from: accounts[8]});}).then(function() {throw new Error();
        }).catch(function(err) {
            assert(err.toString().indexOf('invalid opcode') != -1, "no error thrown when double vote");
        }).then(function() {
            return inst.getProposalVoteCount.call(0);
        }).then(function(value) {
            assert.equal(value.toNumber(), 1, "proposal[0] vote count afer vote");
        }).then(function() {
            return inst.getProposalVoteCount.call(1);
        }).then(function(value) {
            assert.equal(value.toNumber(), 3, "proposal[1] vote count after vote");
        }).then(function() {
            return inst.getWinningProposalId.call();
        }).then(function(value) {
            assert.equal(value.toNumber(), 1, "winning proposal id");
        }).then(function() {
            return inst.getWinningProposalName.call();
        }).then(function(value) {
            assert.equal(value, web3.sha3("alt"), "winning proposal name");
        }).then(done).catch(done);
    });
});