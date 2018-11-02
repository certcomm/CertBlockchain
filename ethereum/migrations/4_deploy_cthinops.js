var CCRegistry = artifacts.require("./CCRegistry.sol");
var CThinBlockAnchorStorage = artifacts.require("./CThinBlockAnchorStorage.sol");
var CThinBlockAnchorOps = artifacts.require("./CThinBlockAnchorOps.sol");
async function setupContract(deployer) {
    await deployer.deploy(CThinBlockAnchorOps);
    registry = await CCRegistry.deployed()
    cthinBlockAnchorStorage = await CThinBlockAnchorStorage.deployed();
    cthinBlockAnchorOps = await CThinBlockAnchorOps.deployed();
    console.log("registry address=" + registry.address)
    console.log("storage address=" + cthinBlockAnchorStorage.address)
    console.log("ops address=" + cthinBlockAnchorOps.address)

    console.log("Injecting registry in contract");
    cthinBlockAnchorOps.injectRegistry(registry.address);

    console.log("registering contract in registry")
    await registry.registerContract("CThinBlockAnchorOps", cthinBlockAnchorOps.address);
    console.log("Adding contract permissions in registry")
    await registry.addPermittedContract("CThinBlockAnchorStorage", "CThinBlockAnchorOps");
}
module.exports = function(deployer) {
deployer
    .then(() => setupContract(deployer))
    .catch(error => {
      console.log(error);
      process.exit(1);
    });
};
