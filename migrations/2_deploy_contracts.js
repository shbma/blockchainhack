var Votechian = artifacts.require("./Votechain.sol");

module.exports = function(deployer, network) {
  if (network == 'development') {
    deployer.deploy(Votechian);
  }
  if (network == 'ropsten') {
    deployer.deploy(Votechian);
  }
};
