# Simple Pet Shop: An Ethereum Decentralized Application

**Source code is not available to read yet before the semester ends (September 14).**

<b>Description:</b><br>

This folder includes a decentralized shopping web application developed based on Truffle ["Pet Shop Tutorial"](https://trufflesuite.com/guides/pet-shop/). The application implemented multiple additional features and provided backend interfaces for several add-on features, achieving blockchain-wide real-time data display and response by on-chain event listening.

<b>Prerequisites:</b>
- Node.js [v12.13.0+] <br>
- lite-server [v2.6.1+] <br>
- Truffle [v5.1.10] <br>
- MetaMask [v10.18.3+] <br>
- Ganache [v2.5.4+] <br>

<b>Setup Instructions</b>

Brief instructions for configuring the DApp are as follows:<br>
1) Run the executable of Ganache and click the "Quickstart", please record the 12 words mnemonic seed phrase provided by Ganache.
2) Open the MetaMask extension and import the Ganache wallet by inputting the seed phrase from the previous step.
3) Add the Ganache testnet to MetaMask using the following information:
- New RPC Url: `HTTP://127.0.0.1:7545` <br>
- Chain ID: `1337` <br>
- Currency Symbol: `ETH` <br>
4) Change the directory to the source folder.
5) Compile the solidity contract:
```
    truffle compile
```
6) Test the contract then migrate it to the blockchain:
```
    truffle test
    truffle migrate
```
7) Start the local web server:
```
    npm run dev
```
8) The application interface should be available to use in the browser after confirming the connection of the MetaMask wallet.
9) To get rid of the built files and reset the blockchain:
```
    truffle networks –clean
```

<br><b>Copyright © 2021 [Weixuan Yang](https://www.linkedin.com/in/weixuanyang/)</b>
