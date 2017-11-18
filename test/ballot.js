var Ballot = artifacts.require("./Ballot.sol");

contract('Ballot', function(accounts) {
  var citizen1 = accounts[1];
  var citizen2 = accounts[2];
  var citizen3 = accounts[3];

  it("should create proposals array in storage", function() {
    var names = ['Ivan','Peter','Nikolaus']; // имена кандидатов
    var contractAddress;

    return Ballot.deployed().then(function(instance) {
      contractAddress = instance.address;
      return instance.startBallot(names); //задаем массив имен кандидатов

    }).then(function(tx){
      var ballot = Ballot.at(contractAddress);
      return ballot.proposals.call(0) //выбираем первого кандидата

    }).then(function(nameVotes0) {
      console.log(nameVotes0); console.log(nameVotes0[0]);
      assert.equal(nameVotes.name, names[0], "Кандидат 1 не совпадает");
    })
  });

  /*it("should set deployer as chairperson", function() {
    return Ballot.deployed().then(function(instance) {
      console.log(instance);
      assert.equal(instance.chairperson, names, "Выложивший контракт не стал председателем");
    })
  });*/

  /*it("should call a function that depends on a linked library", function() {
    var meta;
    var metaCoinBalance;
    var metaCoinEthBalance;

    return MetaCoin.deployed().then(function(instance) {
      meta = instance;
      return meta.getBalance.call(accounts[0]);
    }).then(function(outCoinBalance) {
      metaCoinBalance = outCoinBalance.toNumber();
      return meta.getBalanceInEth.call(accounts[0]);
    }).then(function(outCoinBalanceEth) {
      metaCoinEthBalance = outCoinBalanceEth.toNumber();
    }).then(function() {
      assert.equal(metaCoinEthBalance, 2 * metaCoinBalance, "Library function returned unexpected function, linkage may be broken");
    });
  });*/
  /*it("should send coin correctly", function() {
    var meta;

    // Get initial balances of first and second account.
    var account_one = accounts[0];
    var account_two = accounts[1];

    var account_one_starting_balance;
    var account_two_starting_balance;
    var account_one_ending_balance;
    var account_two_ending_balance;

    var amount = 10;

    return MetaCoin.deployed().then(function(instance) {
      meta = instance;
      return meta.getBalance.call(account_one);
    }).then(function(balance) {
      account_one_starting_balance = balance.toNumber();
      return meta.getBalance.call(account_two);
    }).then(function(balance) {
      account_two_starting_balance = balance.toNumber();
      return meta.sendCoin(account_two, amount, {from: account_one});
    }).then(function() {
      return meta.getBalance.call(account_one);
    }).then(function(balance) {
      account_one_ending_balance = balance.toNumber();
      return meta.getBalance.call(account_two);
    }).then(function(balance) {
      account_two_ending_balance = balance.toNumber();

      assert.equal(account_one_ending_balance, account_one_starting_balance - amount, "Amount wasn't correctly taken from the sender");
      assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
    });
  });*/
});
