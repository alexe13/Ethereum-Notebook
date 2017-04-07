Distributed application for saving, editing and deleting notes stored in Ethereum blockchain. Allows to grant rights to read or  edit your notes to third-party Ethereum addresses.

Installation requirements:

- Node.js
- Truffle Framework
- testrpc or any Ethereum client

Installation:

First, connect to a blockchain network. For testing on a local simulation:

```
~ $ testrpc
```

or for deploying to Ethereum testnet (in case of go-ethereum client):

```
~ $ geth --testnet --fast --rpc --rpcapi db,eth,net,web3,personal --cache=1024  --rpcport 8545 --rpcaddr 127.0.0.1 --rpccorsdomain "*" 
```

then navigate to project folder and run:

```
~ $ npm install
~ $ truffle compile
~ $ truffle migrate --reset
~ $ npm run dev
```
