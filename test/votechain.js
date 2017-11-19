var Votechain = artifacts.require("./Votechain.sol");

contract('Votechain', function(accounts) {
  var ukManAddr = accounts[0];
  var holder1Addr = accounts[1];
  var holder2Addr = accounts[2];
  var alienAddr = accounts[3];

  it("должен установить представителя УК", function(){
    var contractAddress;

    return Votechain.deployed().then(function(votechain){
      contractAddress = votechain.address;
      return votechain.setUkMan(ukManAddr);
    }).then(function(tx){
      var votechain = Votechain.at(contractAddress);
      return votechain.ukMan.call()
    }).then(function(ukMan){
      assert.equal(ukMan, ukManAddr, "Представитель УК не задался");
    })
  })

  it("должен добавить жильца руками представителя УК", function(){
    var contractAddress;
    var newHolder = {
      ethAddress: holder1Addr,
      square: 100,
      realAddress: "Russia;Yekaterinburg;Yeltsina;;3a;102"
    }

    return Votechain.deployed().then(function(votechain){
      contractAddress = votechain.address;
      //установили представителя УК
      return votechain.setUkMan(ukManAddr);

    }).then(function(tx){
      var votechain = Votechain.at(contractAddress);
      //добавили новго жильца от имени представителя УК
      return votechain.addHolder(
        newHolder.ethAddress,
        newHolder.square,
        newHolder.realAddress,
        {from: ukManAddr});

    }).then(function(tx){
      var votechain = Votechain.at(contractAddress);
      //попробовали взять жильца по эфирному адресу из массива
      return votechain.holders.call(holder1Addr)

    }).then(function(holder){
      //сравним площади, если равны - значит факт внесения в список состоялся
      //holder получается не объектом, а массивом [true, 100, "...."]
      assert.equal(holder[1], newHolder.square, "Нового жильца УК внести не смог");
    })
  })

  //ПОТОМ: проверить, что НЕ предствитель УК добавить жильца не сможет

  it("должен деактивировать жильца руками представителя УК", function(){
    var contractAddress;

    return Votechain.deployed().then(function(votechain){
      contractAddress = votechain.address;
      //установили представителя УК
      return votechain.setUkMan(ukManAddr);

    }).then(function(tx){
      var votechain = Votechain.at(contractAddress);
      //добавили новго жильца от имени представителя УК
      return votechain.deactivateHolder(holder1Addr, {from: ukManAddr});

    }).then(function(tx){
      var votechain = Votechain.at(contractAddress);
      //попробовали взять жильца по эфирному адресу из массива
      return votechain.holders.call(holder1Addr)

    }).then(function(holder){
      //сравним площади, если равны - значит факт внесения в список состоялся
      //holder получается не объектом, а массивом [false, 100, "...."]
      assert.equal(holder[0], false, "Деактивировать жильца представитель УК не смог");
    })
  })

  it("должен руками жильца создать вопрос для голосования", function(){
    var contractAddress;
    var questionText = "Make house walls pink";

    return Votechain.deployed().then(function(votechain){
      contractAddress = votechain.address;
      //создаем вопрос
      return votechain.addQuestion(holder1Addr, questionText)

    }).then(function(tx){
      var votechain = Votechain.at(contractAddress);
      //получили длину = номер свежего вопроса + 1
      return votechain.getQuestionsLength.call()

    }).then(function(length){
      var votechain = Votechain.at(contractAddress);
      //получили сам вопрос по номеру
      return votechain.questions.call(length-1)

    }).then(function(question){
      //сравним тексты
      //question получается не объектом, а массивом [.., .., ...]
      assert.equal(question[1], questionText, "Жилец не смог добавить вопрос для голосования");
    })
  })

  //ПОТОМ: проверить, что НЕ жилец и НЕ УК добавить вопрос не сможет

  it("должен руками автора вопроса остановить голосование", function(){
    var contractAddress;
    var questionText = "Make house walls yellow";
    var questionPos = false;

    return Votechain.deployed().then(function(votechain){
      contractAddress = votechain.address;
      //создаем вопрос
      return votechain.addQuestion(holder1Addr, questionText)

    }).then(function(tx){
      var votechain = Votechain.at(contractAddress);
      //получили длину массива вопросов = номер свежего вопроса + 1
      return votechain.getQuestionsLength.call()

    }).then(function(length){
      console.log('length='+length)
      var votechain = Votechain.at(contractAddress);
      questionPos = length-1;
      //по номеру взяли вопрос и остановили
      console.log(questionPos);
      //return votechain.stopQuestion(questionPos)

    }).then(function(tx){
      var votechain = Votechain.at(contractAddress);
      //получили сам вопрос по номеру
      return votechain.questions.call(questionPos)

    }).then(function(question){
      //сравним тексты
      //question получается не объектом, а массивом [.., .., ...]
      //assert.equal(question[2], true, "Автор вопроса не смог остановить голосование");
    })
  })


  /*it("should create proposals array in storage", function() {
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
  });*/

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
