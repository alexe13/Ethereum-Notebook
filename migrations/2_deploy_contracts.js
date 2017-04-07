var Notebook = artifacts.require("./Notebook.sol");

module.exports = function(deployer) {
  deployer.deploy(Notebook);
};
