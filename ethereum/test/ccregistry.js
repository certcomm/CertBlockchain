const CCRegistry = artifacts.require("CCRegistry")
const CThinBlockAnchorStorage = artifacts.require("CThinBlockAnchorStorage")
const CThinBlockAnchorOps = artifacts.require("CThinBlockAnchorOps")
contract('CCRegistry test', async (accounts) => {
  let registry = null;
  let tmail21Governor = accounts[1];
  let fooGovernor = accounts[2];
  let tmail21DomainName="tmail21.com"
  let fooDomainName="foo.com"

  beforeEach('setup contract for each test', async() => {
    registry = await CCRegistry.deployed();
  }),
  it("should register tmail21 governor", async () => {
    assert.isFalse(await registry.isGovernor(tmail21Governor));
    assert.isFalse(await registry.isGovernor(fooGovernor));
    await registry.registerGovernor(tmail21DomainName, tmail21Governor);
    await registry.registerGovernor(fooDomainName, fooGovernor);
    console.log(await registry.getGovernorDomainHash(tmail21Governor));
    console.log(await registry.getGovernorDomainHash(fooGovernor));
    assert.isTrue(await registry.isGovernor(tmail21Governor));
    assert.isTrue(await registry.isGovernor(fooGovernor));
    await registry.deregisterGovernor(tmail21DomainName);
    await registry.deregisterGovernor(fooDomainName);
    assert.isFalse(await registry.isGovernor(tmail21Governor));
    assert.isFalse(await registry.isGovernor(fooGovernor));
  })
  ,it("should replace tmail21 governor address", async () => {
    let tmail21NewGovernor = accounts[3];
    assert.isFalse(await registry.isGovernor(tmail21Governor));
    assert.isFalse(await registry.isGovernor(tmail21NewGovernor));
    await registry.registerGovernor(tmail21DomainName, tmail21Governor);
    await registry.replaceGovernorAddress(tmail21DomainName, tmail21NewGovernor);
    assert.isFalse(await registry.isGovernor(tmail21Governor));
    assert.isTrue(await registry.isGovernor(tmail21NewGovernor));

    await registry.deregisterGovernor(tmail21DomainName);
    assert.isFalse(await registry.isGovernor(tmail21NewGovernor));
  })
  ,it("should register contract", async () => {
    let storageInstance = await CThinBlockAnchorStorage.new(registry.address);
    await registry.registerContract("CThinBlockAnchorStorage", storageInstance.address);
    let opsInstance = await CThinBlockAnchorOps.new(registry.address);
    await registry.registerContract("CThinBlockAnchorOps", opsInstance.address);
    assert.equal(await registry.getContractAddr("CThinBlockAnchorStorage"), storageInstance.address);
    assert.equal(await registry.getContractAddr("CThinBlockAnchorOps"), opsInstance.address);
    let opsInstanceV2 = await CThinBlockAnchorOps.new(registry.address);
    await registry.registerContract("CThinBlockAnchorOps", opsInstanceV2.address);
    assert.equal(await registry.getContractAddr("CThinBlockAnchorOps"), opsInstanceV2.address);
  })
  ,it("test contract permissions", async () => {
    let storageInstance = await CThinBlockAnchorStorage.new(registry.address);
    await registry.registerContract("CThinBlockAnchorStorage", storageInstance.address);
    let opsInstance = await CThinBlockAnchorOps.new(registry.address);
    await registry.registerContract("CThinBlockAnchorOps", opsInstance.address);

    await registry.removePermittedContract("CThinBlockAnchorStorage", "CThinBlockAnchorOps");
    assert.isFalse(await registry.isPermittedContract(storageInstance.address, opsInstance.address));
    await registry.addPermittedContract("CThinBlockAnchorStorage", "CThinBlockAnchorOps");
    assert.isTrue(await registry.isPermittedContract(storageInstance.address, opsInstance.address));
    //register a new version of OPS contract
    let opsInstanceV2 = await CThinBlockAnchorOps.new(registry.address);
    await registry.registerContract("CThinBlockAnchorOps", opsInstanceV2.address);
    assert.isFalse(await registry.isPermittedContract(storageInstance.address, opsInstance.address));
    assert.isTrue(await registry.isPermittedContract(storageInstance.address, opsInstanceV2.address));

  })
})
