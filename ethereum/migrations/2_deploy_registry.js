var CCRegistry = artifacts.require("./CCRegistry.sol");
async function setupContract(deployer) {
    await deployer.deploy(CCRegistry);
    registry = await CCRegistry.deployed()
    console.log("registry deployed at " + registry.address)
}
module.exports = function(deployer) {
deployer
    .then(() => setupContract(deployer))
    .catch(error => {
      console.log(error);
      process.exit(1);
    });
};
