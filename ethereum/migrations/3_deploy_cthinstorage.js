var CCRegistry = artifacts.require("./CCRegistry.sol");
var CThinBlockAnchorStorage = artifacts.require("./CThinBlockAnchorStorage.sol");
async function setupContract(deployer) {
    await deployer.deploy(CThinBlockAnchorStorage);
    registry = await CCRegistry.deployed()
    cthinBlockAnchorStorage = await CThinBlockAnchorStorage.deployed();
    console.log("registry address=" + registry.address)
    console.log("storage address=" + cthinBlockAnchorStorage.address)

    console.log("Injecting registry in contract");
    cthinBlockAnchorStorage.injectRegistry(registry.address);
    console.log("registering contract in registry")
    await registry.registerContract("CThinBlockAnchorStorage", cthinBlockAnchorStorage.address);
}
module.exports = function(deployer) {
deployer
    .then(() => setupContract(deployer))
    .catch(error => {
      console.log(error);
      process.exit(1);
    });
};
