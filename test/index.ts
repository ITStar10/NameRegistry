import chai from "chai"
import chaiAsPromised from "chai-as-promised"
import { solidity } from 'ethereum-waffle'
import { expect } from "chai"
import { artifacts, ethers } from "hardhat";

import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { BigNumber } from "@ethersproject/bignumber"

chai.use(solidity)
chai.use(chaiAsPromised)

import hre from "hardhat";
import { NameRegistry } from "../typechain";

describe("NameRegistry", function () {
  let contract: NameRegistry
  let accountList : SignerWithAddress[];

  const registerFund = ethers.utils.parseEther('0.1');
  
  const testNames = ['John', 'Smith Elba', 'Bill Clin'];
  const testDIDs = [
    '0x181aB2d2F0143cd2046253c56379f7eDb1E9C133',
    '0x2b3f34e9d4b127797ce6244ea341a83733ddd6e4',
    '0x327c1FEd75440d4c3fA067E633A3983D211f0dfD'
  ];

  const zeroAddress = '0x0000000000000000000000000000000000000000';

  this.beforeAll(async function(){
    await hre.network.provider.send("hardhat_reset")
    accountList = await ethers.getSigners();

    const contractFactory = await ethers.getContractFactory('NameRegistry');
    contract = await contractFactory.deploy();
    console.log('NameRegistry deployed at ', contract.address);
  })

  it ("Register", async function() {
    // Insufficient fund
    await expect(contract.register(testNames[0], testDIDs[0])).to.be.rejectedWith('Insufficient fund');

    console.log("Balance before register : ",ethers.utils.formatEther(await accountList[0].getBalance()));
    await contract.register(testNames[0], testDIDs[0], { value: registerFund });
    console.log("Balance After register : ",ethers.utils.formatEther(await accountList[0].getBalance()));

    // Invalid address
    await expect(contract.register(testNames[0], '0x0', { value: registerFund })).to.be.rejectedWith('invalid address');
    // Zero address
    await expect(contract.register(testNames[0], zeroAddress, { value: registerFund })).to.be.rejectedWith('Invalid zero address');
    // Duplcation Name
    await expect(contract.register(testNames[0], testDIDs[1], { value: registerFund })).to.be.rejectedWith('Name already registered');
    await expect(contract.connect(accountList[1]).register(testNames[0], testDIDs[1], { value: registerFund })).to.be.rejectedWith('Name already registered');
    // Duplication DID
    await expect(contract.register(testNames[1], testDIDs[0], { value: registerFund })).to.be.rejectedWith('DID already registered');
    await expect(contract.connect(accountList[1]).register(testNames[1], testDIDs[0], { value: registerFund })).to.be.rejectedWith('DID already registered');
    // Case-sensitive test
    let uppercaseDID = testDIDs[0].toUpperCase().substring(2);
    uppercaseDID = '0x' + uppercaseDID;
    await expect(contract.register(testNames[1], uppercaseDID, { value: registerFund })).to.be.rejectedWith('DID already registered');
  })

  it ("Unregister", async function() {
    // Unregistered name
    await expect(contract.unregister(testNames[1])).to.be.rejectedWith('Unregistered name');
    // Not a Owner
    await expect(contract.connect(accountList[1]).unregister(testNames[0])).to.be.rejectedWith('Not a owner');

    console.log("Balance before unregister : ",ethers.utils.formatEther(await accountList[0].getBalance()));
    await contract.unregister(testNames[0]);
    console.log("Balance after unregister : ",ethers.utils.formatEther(await accountList[0].getBalance()));
  })

  it ("Find Test", async function() {
    // Register for Test
    for (let i = 0; i < 2; i++) {
      await contract.register(testNames[i], testDIDs[i], {value: registerFund});
    }

    // Find Test
    for (let i = 0; i < 2; i++) {
      // Finid DID
      expect((await contract.findDid(testNames[i])).toUpperCase()).to.be.equals(testDIDs[i].toUpperCase());
      // Find Name
      expect(await contract.findName(testDIDs[i])).to.be.equals(testNames[i]);
    }

    // Revert : Unregistered Name & DID
    await expect(contract.findDid(testNames[2])).to.be.rejectedWith('Unregistered name');
    await expect(contract.findName(testDIDs[2])).to.be.rejectedWith('Unregistered DID');

    // Revert : Not a owner
    await expect(contract.connect(accountList[1]).findName(testDIDs[0])).to.be.rejectedWith('Not a owner');
    await expect(contract.connect(accountList[1]).findDid(testNames[0])).to.be.rejectedWith('Not a owner');

    // Unregister to retrieve funds
    for (let i = 0; i < 2; i++) {
      await contract.unregister(testNames[i]);
    }
  })
});
