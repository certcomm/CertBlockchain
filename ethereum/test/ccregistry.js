const CCRegistry = artifacts.require("CCRegistry")
const CThinBlockAnchorStorage = artifacts.require("CThinBlockAnchorStorage")
const CThinBlockAnchorOps = artifacts.require("CThinBlockAnchorOps")
contract('CCRegistry test', async (accounts) => {
  let registry = null;
  let storageInstance = null;
  let opsInstance = null;
  let tmail21Governor = accounts[1];
  let fooGovernor = accounts[2];
  let tmail21DomainName="tmail21.com"
  let fooDomainName="foo.com"

  beforeEach('setup contract for each test', async() => {
    registry = await CCRegistry.deployed();
    storageInstance = await CThinBlockAnchorStorage.new();
    opsInstance = await CThinBlockAnchorOps.new();
    await storageInstance.injectRegistry(registry.address);
    await opsInstance.injectRegistry(registry.address);
  }),
  it("should register tmail21 governor", async () => {
    assert.isFalse(await registry.isGovernor(tmail21Governor));
    assert.isFalse(await registry.isGovernor(fooGovernor));
    let watcher = registry.GovernorRegistered();
    await registry.registerGovernor(tmail21DomainName, tmail21Governor);
    events = await watcher.get();
    assert.equal(events.length, 1);
    assert.equal(events[0].args.domainName.valueOf(), tmail21DomainName);
    assert.equal(events[0].args.governorAddress.valueOf(), tmail21Governor);
    await registry.registerGovernor(fooDomainName, fooGovernor);
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
    let watcher = registry.GovernorReplaced();
    await registry.replaceGovernorAddress(tmail21DomainName, tmail21NewGovernor);
    events = await watcher.get();
    assert.equal(events.length, 1);
    assert.equal(events[0].args.domainName.valueOf(), tmail21DomainName);
    assert.equal(events[0].args.oldGovernorAddress.valueOf(), tmail21Governor);
    assert.equal(events[0].args.newGovernorAddress.valueOf(), tmail21NewGovernor);
    assert.isFalse(await registry.isGovernor(tmail21Governor));
    assert.isTrue(await registry.isGovernor(tmail21NewGovernor));

    watcher = registry.GovernorDeRegistered();
    await registry.deregisterGovernor(tmail21DomainName);
    events = await watcher.get();
    assert.equal(events.length, 1);
    assert.equal(events[0].args.domainName.valueOf(), tmail21DomainName);
    assert.isFalse(await registry.isGovernor(tmail21NewGovernor));
  })
  ,it("should register contract", async () => {
    let watcher = registry.ContractRegistered()
    await registry.registerContract("CThinBlockAnchorStorage", storageInstance.address);
    events = await watcher.get();
    assert.equal(events.length, 1);
    assert.equal(events[0].args.name.valueOf(), "CThinBlockAnchorStorage");
    assert.equal(events[0].args.contractAddress.valueOf(), storageInstance.address);
    await registry.registerContract("CThinBlockAnchorOps", opsInstance.address);
    assert.equal(await registry.getContractAddr("CThinBlockAnchorStorage"), storageInstance.address);
    assert.equal(await registry.getContractAddr("CThinBlockAnchorOps"), opsInstance.address);

    let opsInstanceV2 = await CThinBlockAnchorOps.new();
    await opsInstanceV2.injectRegistry(registry.address);
    await registry.registerContract("CThinBlockAnchorOps", opsInstanceV2.address);
    assert.equal(await registry.getContractAddr("CThinBlockAnchorOps"), opsInstanceV2.address);
  })
  ,it("test contract permissions", async () => {
    await registry.registerContract("CThinBlockAnchorStorage", storageInstance.address);
    await registry.registerContract("CThinBlockAnchorOps", opsInstance.address);

    await registry.removePermittedContract("CThinBlockAnchorStorage", "CThinBlockAnchorOps");
    assert.isFalse(await registry.isPermittedContract(storageInstance.address, opsInstance.address));
    let watcher = registry.ContractPermissionGranted()
    await registry.addPermittedContract("CThinBlockAnchorStorage", "CThinBlockAnchorOps");
    assert.isTrue(await registry.isPermittedContract(storageInstance.address, opsInstance.address));
    events = await watcher.get();
    assert.equal(events[0].args.called.valueOf(), "CThinBlockAnchorStorage");
    assert.equal(events[0].args.caller.valueOf(), "CThinBlockAnchorOps");
    //register a new version of OPS contract
    let opsInstanceV2 = await CThinBlockAnchorOps.new();
    await opsInstanceV2.injectRegistry(registry.address);
    await registry.registerContract("CThinBlockAnchorOps", opsInstanceV2.address);
    assert.isFalse(await registry.isPermittedContract(storageInstance.address, opsInstance.address));
    assert.isTrue(await registry.isPermittedContract(storageInstance.address, opsInstanceV2.address));

  })
})
