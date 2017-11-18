const Web3 = require('web3');
const TruffleConfig = require('../truffle');
const personal = require('../personal.js');

var Migrations = artifacts.require("./Migrations.sol");

/*module.exports = function(deployer) {
  deployer.deploy(Migrations);
};*/

module.exports = function(deployer, network, addresses) {
  const config = TruffleConfig.networks[network];

  if (network !== 'development') {
    const web3 = new Web3(new Web3.providers.HttpProvider('http://' + config.host + ':' + config.port));

    console.log('>> Unlocking account ' + config.from);
    web3.personal.unlockAccount(config.from, personal.account_password, 36000);
  }

  console.log('>> Deploying migration');
  deployer.deploy(Migrations);
};
