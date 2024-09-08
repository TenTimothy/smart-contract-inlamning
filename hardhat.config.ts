import { HardhatUserConfig, vars } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
const ETHERSCAN_API_KEY = vars.get('ETHERSCANAPI_KEY');
const ALCHEMY_API_KEY = vars.get('ALCHEMY_API_KEY');
const SEPOLIA_API_KEY = vars.get('SEPOLIA_API_KEY');

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [SEPOLIA_API_KEY],
    },
    localhost: {
      url: "http://127.0.0.1:8545", 
    },
  },
};

export default config;