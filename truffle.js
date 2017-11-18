module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8550,
      network_id: "*", // Match any network id      
    },
    ropsten: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "3", // ropsten testne#3
      from: '0x091164497aCfF1Ce63ECe2F020A989121361Ac58',
      gas: 2900000
    }
  }
};
