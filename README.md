# Setup Environment
Assumed : node & npm are already installed on your OS
Note : All commands below should be run in terminal(Ubuntu) or command prompt(Windows).

install yarn :
    npm install --global yarn
    Reference : https://classic.yarnpkg.com/lang/en/docs/install/#windows-stable

install npx:
    yarn global add npx
    or
    npm install -g npx   

install hardhat:
    yarn --dev add hardhat
    or
    npm install --save-dev hardhat
    

# Project setup
install dependencies:
    Inside project folder install dependencies with following command

    yarn install

setup environment variables:
    create .env file inside project and fill the content like following. Here PRIVATE_KEY is one of your MetaMask wallet address's private key. It's for deploying contract to chains.

GANACHE_MNEMONIC="year year year year year year year year year year year year"
PRIVATE_KEY="0xba34556666666666666666666666666666666666666666666666666666666e"
ROPSTEN_URL="https://eth-ropsten.alchemyapi.io/v2/<YOUR ALCHEMY KEY>"
ETHERSCAN_API_KEY="ABC123ABC123ABC123ABC123ABC123ABC1"
    
# Test
    Inside project folder, run following command

    npx hardhat test test/index.ts

# Deploy
    At the moment, project is configured for 3 networks to be deployed.
    Deploy with following command

    npx hardhat run scripts/deploy.ts --network <networkname>

    <networkname> can be one of following:
    bsctestnet
    bscmainnet
    cronosmainnet

    Example : Deploy to bsc testnet
    npx hardhat run scripts/deploy.ts --network bsctestnet
