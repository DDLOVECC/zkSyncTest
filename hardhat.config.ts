import "@matterlabs/hardhat-zksync-deploy";
import "@matterlabs/hardhat-zksync-solc";
import "@matterlabs/hardhat-zksync-verify";

module.exports = {
  zksolc: {
    version: "1.3.10",
    compilerSource: "binary",
    settings: {},
  },
  defaultNetwork: "zkTestnet",

  networks: {
    zkTestnet: {
      url: "https://zksync2-testnet.zksync.dev",
      ethNetwork: "goerli", // RPC URL of the network (e.g. `https://goerli.infura.io/v3/<API_KEY>`)
      zksync: true,
      verifyURL: 'https://zksync2-testnet-explorer.zksync.dev/contract_verification'
    },
  },
  solidity: {
    version: "0.8.18",
  },
};
