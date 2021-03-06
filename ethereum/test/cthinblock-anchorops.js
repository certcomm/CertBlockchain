const CCRegistry = artifacts.require("CCRegistry")
const CThinBlockAnchorStorage = artifacts.require("CThinBlockAnchorStorage")
const CThinBlockAnchorOps = artifacts.require("CThinBlockAnchorOps")
const shardNum = 0;
contract('CThinBlockAnchorOps test', async (accounts) => {
  let registry = null;
  let instance = null;
  let tmail21Governor = accounts[1];
  let tmail21DomainName="tmail21.com"
  beforeEach('setup contract for each test', async() => {
    registry = await CCRegistry.deployed();
    let storageInstance = await CThinBlockAnchorStorage.deployed();
    await storageInstance.injectRegistry(registry.address);
    await registry.registerContract("CThinBlockAnchorStorage", storageInstance.address);
    let opsInstance = await CThinBlockAnchorOps.deployed();
    await opsInstance.injectRegistry(registry.address);

    await registry.registerContract("CThinBlockAnchorOps", opsInstance.address);
    await registry.addPermittedContract("CThinBlockAnchorStorage", "CThinBlockAnchorOps");
    if(!await registry.isGovernor(tmail21Governor)) {
        await registry.registerGovernor(tmail21DomainName, tmail21Governor);
        assert.isTrue(await registry.isGovernor(tmail21Governor));
    }
    let cThinBlockAnchorOpsAddress = await registry.getContractAddr("CThinBlockAnchorOps")
    instance = CThinBlockAnchorOps.at(cThinBlockAnchorOpsAddress);
  })
  ,
  it("should add cBlocknum 1", async () => {
    let cblockHash = "88bcd5a4398c6dca70123030a2df3bebee3f85736c607292dd2751eeba8c7ea3";
    let merkleRootHash = "7204098e42efb8f64fe874243bfd28e61f31520b288fa1a0cfac0a6a95db0000";
    let cblockNum = 1;
    let watcher = instance.CThinBlockAnchorCreated();
    assert.isFalse(await instance.cThinBlockAnchorExists(tmail21DomainName, shardNum,cblockNum, {from: tmail21Governor}));
    await instance.addCThinBlockAnchor(shardNum,cblockNum, cblockHash, merkleRootHash, {from: tmail21Governor});
    assert.isTrue(await instance.cThinBlockAnchorExists(tmail21DomainName, shardNum,cblockNum, {from: tmail21Governor}));
    events = await watcher.get();
    assert.equal(events.length, 1);
    assert.equal(events[0].args.shard.valueOf(), shardNum);
    assert.equal(events[0].args.cblockNum.valueOf(), cblockNum);
    let cThinBlockAnchor = await instance.getCThinBlockAnchor(tmail21DomainName, shardNum,cblockNum, {from: tmail21Governor});
    assert.equal(cThinBlockAnchor[0], cblockHash);
    assert.equal(cThinBlockAnchor[1], merkleRootHash);

    await instance.addExternalCThinBlockRef(shardNum,cblockNum,"ipfs","fooUri1", {from: tmail21Governor});
    let externalCThinBlockRef = await instance.getExternalCThinBlockRef(tmail21DomainName, shardNum,cblockNum,"ipfs", {from: tmail21Governor});
    assert.equal(externalCThinBlockRef, "fooUri1");
  })
  ,it("should add cBlocknum 2", async () => {
    let cblockHash = "88bcd5a4398c6dca70123030a2df3bebee3f85736c607292dd2751eeba8c7ea3";
    let merkleRootHash = "7204098e42efb8f64fe874243bfd28e61f31520b288fa1a0cfac0a6a95db0000";
    let cblockNum = 2;
    assert.isFalse(await instance.cThinBlockAnchorExists(tmail21DomainName, shardNum,cblockNum, {from: tmail21Governor}));

    await instance.addCThinBlockAnchor(shardNum,cblockNum, cblockHash, merkleRootHash, {from: tmail21Governor});
    assert.isTrue(await instance.cThinBlockAnchorExists(tmail21DomainName, shardNum,cblockNum, {from: tmail21Governor}));
    let cThinBlockAnchor = await instance.getCThinBlockAnchor(tmail21DomainName, shardNum,cblockNum, {from: tmail21Governor});
    assert.equal(cThinBlockAnchor[0], cblockHash);
    assert.equal(cThinBlockAnchor[1], merkleRootHash);

    await instance.addExternalCThinBlockRef(shardNum,cblockNum,"ipfs","fooUri1", {from: tmail21Governor});
    await instance.addExternalCThinBlockRef(shardNum,cblockNum,"bitcoin","barUri1", {from: tmail21Governor});

    let externalCThinBlockRef = await instance.getExternalCThinBlockRef(tmail21DomainName, shardNum,cblockNum,"ipfs", {from: tmail21Governor});
    assert.equal(externalCThinBlockRef, "fooUri1");
    externalCThinBlockRef = await instance.getExternalCThinBlockRef(tmail21DomainName, shardNum,cblockNum,"bitcoin", {from: tmail21Governor});
    assert.equal(externalCThinBlockRef, "barUri1");
  })
  ,it("should add cBlocknum 3 using real hash functions", async () => {
    let cblockHash = web3.sha3("This is a test cblock3");
    let merkleRootHash = web3.sha3("This is test merkle3");
    let cblockNum = 3;
    assert.isFalse(await instance.cThinBlockAnchorExists(tmail21DomainName, shardNum,cblockNum, {from: tmail21Governor}));

    await instance.addCThinBlockAnchor(shardNum,cblockNum, cblockHash, merkleRootHash, {from: tmail21Governor});
    assert.isTrue(await instance.cThinBlockAnchorExists(tmail21DomainName, shardNum,cblockNum, {from: tmail21Governor}));
    let cThinBlockAnchor = await instance.getCThinBlockAnchor(tmail21DomainName, shardNum,cblockNum, {from: tmail21Governor});
    assert.equal(cThinBlockAnchor[0], cblockHash);
    assert.equal(cThinBlockAnchor[1], merkleRootHash);
  })
  ,it("should have access to data after governor address replace", async () => {
    let fooGovernor = accounts[3];
    let fooNewGovernor = accounts[4];
    let fooDomainName="foo.com"
    await registry.registerGovernor(fooDomainName, fooGovernor);

    let cblockHash = web3.sha3("This is a test cblock4");
    let merkleRootHash = web3.sha3("This is test merkle4");
    let cblockNum = 4;
    await instance.addCThinBlockAnchor(shardNum,cblockNum, cblockHash, merkleRootHash, {from: fooGovernor});
    assert.isTrue(await instance.cThinBlockAnchorExists(fooDomainName, shardNum,cblockNum, {from: fooGovernor}));
    let cThinBlockAnchor = await instance.getCThinBlockAnchor(fooDomainName, shardNum,cblockNum, {from: fooGovernor});
    assert.equal(cThinBlockAnchor[0], cblockHash);
    assert.equal(cThinBlockAnchor[1], merkleRootHash);
    //replace governor address
    await registry.replaceGovernorAddress(fooDomainName, fooNewGovernor);
    assert.isTrue(await instance.cThinBlockAnchorExists(fooDomainName, shardNum,cblockNum, {from: fooNewGovernor}));
    cThinBlockAnchor = await instance.getCThinBlockAnchor(fooDomainName, shardNum,cblockNum, {from: fooNewGovernor});
    assert.equal(cThinBlockAnchor[0], cblockHash);
    assert.equal(cThinBlockAnchor[1], merkleRootHash);

    await registry.deregisterGovernor(fooDomainName);

  })
})
