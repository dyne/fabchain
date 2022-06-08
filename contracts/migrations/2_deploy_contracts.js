var Faucet = artifacts.require("Faucet");
var ERC20WithDetails = artifacts.require("ERC20WithDetails");

module.exports = function(deployer) {
  deployer.deploy(Faucet);
  deployer.deploy(ERC20WithDetails);
};
