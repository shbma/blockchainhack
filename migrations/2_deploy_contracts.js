var Ballot = artifacts.require("./Ballot.sol");


module.exports = function(deployer, network) {
  if (network == 'development') {
    deployer.deploy(Ballot);
  }
  if (network == 'ropsten') {
    deployer.deploy(Ballot);
  }
};
