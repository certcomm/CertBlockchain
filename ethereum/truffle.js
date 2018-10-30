let secrets = require('../../secrets/secrets');
const WalletProvider = require("truffle-wallet-provider");
const Wallet = require('ethereumjs-wallet');

let mainNetPrivateKey = new Buffer(secrets.mainnetPK, "hex");
let mainNetWallet = Wallet.fromPrivateKey(mainNetPrivateKey);
let mainNetProvider = new WalletProvider(mainNetWallet, "https://mainnet.infura.io/" + secrets.infuraKey);

let rinkebyPrivateKey = new Buffer(secrets.rinkebyPK, "hex");
let rinkebyWallet = Wallet.fromPrivateKey(rinkebyPrivateKey);
let rinkebyProvider = new WalletProvider(rinkebyWallet,  "https://rinkeby.infura.io/" + secrets.infuraKey);

let ropstenPrivateKey = new Buffer(secrets.ropstenPK, "hex");
let ropstenWallet = Wallet.fromPrivateKey(ropstenPrivateKey);
let ropstenProvider = new WalletProvider(ropstenWallet,  "https://ropsten.infura.io/" + secrets.infuraKey);

//var HDWalletProvider = require("truffle-hdwallet-provider");
//var infura_apikey = "Rfiz1l4YFxXO9GRgpOaB";
//var mnemonic = "lyrics draw donor gather keen escape coconut project glue gaze eagle gain";

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 7545,
      network_id: "*" // Match any network id
    },
    rinkeby: {
      provider:()=>rinkebyProvider,
      gas: 4500000,
      network_id: "4" // Match any network id,
    },
    ropsten: {
      provider:()=>ropstenProvider,
      gas: 4500000,
      network_id: "3" // Match any network id,
    },
//    rinkeby: {
//      provider:()=>new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/"+infura_apikey),
//      network_id: "4" // Match any network id,
//    },
  }
};
