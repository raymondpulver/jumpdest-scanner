'use strict';

const Test = artifacts.require('Test.sol');
const emasm = require('emasm');
const ethers = require('ethers');

const provider = new ethers.providers.Web3Provider(Test.currentProvider);

contract('Test.sol', () => {
  it('should compute a jumpdeset map', async () => {
    const runtimeCode = emasm([
      '0x1',
      '0x2',
      '0x3',
      '0x4',
      '0x5',
      'woop',
      ['woop', ['0x1']]
    ]);
    const factory = new ethers.ContractFactory(Test.abi, Test.bytecode, provider.getSigner());
    const tx = factory.getDeployTransaction(runtimeCode);
    console.log(await provider.send('eth_call', [{
      data: tx.data
    }, 'latest']));
  });
});
