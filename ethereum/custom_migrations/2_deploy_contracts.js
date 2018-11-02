var CCRegistry = artifacts.require("./CCRegistry.sol");
var CThinBlockAnchorStorage = artifacts.require("./CThinBlockAnchorStorage.sol");
var CThinBlockAnchorOps = artifacts.require("./CThinBlockAnchorOps.sol");
async function setupRegistry(deployer) {
    await deployer.deploy(CCRegistry);
    await deployer.deploy(CThinBlockAnchorStorage);
    await deployer.deploy(CThinBlockAnchorOps);
    registry = await CCRegistry.deployed()
    cthinBlockAnchorStorage = await CThinBlockAnchorStorage.deployed();
    cthinBlockAnchorOps = await CThinBlockAnchorOps.deployed();

    cthinBlockAnchorStorage.injectRegistry(registry.address);
    cthinBlockAnchorOps.injectRegistry(registry.address);


    await registry.registerContract("CThinBlockAnchorStorage", cthinBlockAnchorStorage.address);
    await registry.registerContract("CThinBlockAnchorOps", cthinBlockAnchorOps.address);
    await registry.addPermittedContract("CThinBlockAnchorStorage", "CThinBlockAnchorOps");
}
module.exports = function(deployer) {
deployer
    .then(() => setupRegistry(deployer))
    .catch(error => {
      console.log(error);
      process.exit(1);
    });
};
