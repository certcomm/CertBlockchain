const CCRegistry = artifacts.require("CCRegistry")
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
})
