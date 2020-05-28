const Migrations = artifacts.require('Migrations');
console.log('woop');
module.exports = async function(deployer) {
  await deployer.deploy(Migrations);
};
