const fs = require('fs');
const HDWalletProvider = require('@truffle/hdwallet-provider');
const mnemonic = 'unaware arrive typical brisk neutral mean rubber live describe pass link hair sell globe deputy'
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
    },
    ropsten: {
      provider: () => new HDWalletProvider(mnemonic, `https://ropsten.infura.io/v3/5ed4c80ac0164fe0bb5cca71adfca0a6`),
      network_id: 3,
      gas: 5500000,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    abs_medical_member1_member1: {
      network_id: "*",
      gasPrice: 0,
      provider: new HDWalletProvider(mnemonic, "https://member1.blockchain.azure.com:3200/skJqTteML8Y6LIQ5y_-a4PF-")
    }
  },
  mocha: {},
  compilers: {
    solc: {}
  }
};
