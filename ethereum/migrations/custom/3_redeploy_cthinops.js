var CCRegistry = artifacts.require("./CCRegistry.sol");
var CThinBlockAnchorOps = artifacts.require("./CThinBlockAnchorOps.sol");
async function setupRegistry(deployer) {
    await deployer.deploy(CThinBlockAnchorOps);
    registry = await CCRegistry.deployed()
    cthinBlockAnchorOps = await CThinBlockAnchorOps.deployed();

    cthinBlockAnchorOps.injectRegistry(registry.address);


    await registry.registerContract("CThinBlockAnchorOps", cthinBlockAnchorOps.address);
}
module.exports = function(deployer) {
deployer
    .then(() => setupRegistry(deployer))
    .catch(error => {
      console.log(error);
      process.exit(1);
    });
};
