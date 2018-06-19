var CCRegistry = artifacts.require("./CCRegistry.sol");
var CThinBlockAnchorStorage = artifacts.require("./CThinBlockAnchorStorage.sol");
module.exports = function(deployer) {
  const setupRegistry = async() => {
    await deployer.deploy(CCRegistry);
    registry = await CCRegistry.deployed()

    cthinBlockAnchorStorage = await deployer.deploy(CThinBlockAnchorStorage, registry.address);
    registry.registerContract("CThinBlockAnchorStorage", cthinBlockAnchorStorage.address);
  }
  setupRegistry();
};
