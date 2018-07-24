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

//module.exports = function(deployer) {
//  deployer.deploy(CCRegistry).then(()=>{
//    CCRegistry.deployed().then(function(registry) {
//        deployer.deploy(CThinBlockAnchorStorage, registry.address).then(()=>{
//            console.log("Deployed CThinBlockAnchorStorage");
//            deployer.deploy(CThinBlockAnchorOps, registry.address).then(()=>{
//                console.log("Deployed CThinBlockAnchorOps");
//                CThinBlockAnchorStorage.deployed().then(function(cthinBlockAnchorStorage) {
//                    registry.registerContract("CThinBlockAnchorStorage", cthinBlockAnchorStorage.address).then(()=>{
//                        console.log("Registered CThinBlockAnchorStorage");
//                        CThinBlockAnchorOps.deployed().then(function(cthinBlockAnchorOps) {
//                            registry.registerContract("CThinBlockAnchorOps", cthinBlockAnchorOps.address).then(()=>{
//                                console.log("Registered CThinBlockAnchorOps");
//                                registry.addPermittedContract("CThinBlockAnchorStorage", "CThinBlockAnchorOps").then(()=>{
//                                    console.log("Added permitted contract");
//                                });
//                            });
//                        });
//                    });
//                });
//            });
//        });
//    });
//  });
//};