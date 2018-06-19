const CCRegistry = artifacts.require("CCRegistry")
const CThinBlockAnchorStorage = artifacts.require("CThinBlockAnchorStorage")
const shardNum = 0;
contract('CThinBlockAnchorStorage test', async (accounts) => {
  let registry = null;
  let instance = null;
  beforeEach('setup contract for each test', async() => {
    registry = await CCRegistry.deployed();
    instance = await CThinBlockAnchorStorage.new(registry.address);
    registry.registerContract("CThinBlockAnchorStorage", instance.address)
  }),
  it("should add cBlocknum 1", async () => {
     let cblockHash = "703836587B41B5B7326E63C8AB492F61";
     let merkleRootHash = "403836587B41B5B7326E63C8AB492F61";
     let cblockNum = 1;
     assert.isFalse(await instance.cThinBlockAnchorExists(shardNum,cblockNum));

     await instance.addCThinBlockAnchor(shardNum,cblockNum, cblockHash, merkleRootHash);
     assert.isTrue(await instance.cThinBlockAnchorExists(shardNum,cblockNum));
     let cThinBlockAnchor = await instance.getCThinBlockAnchor(shardNum,cblockNum);
     assert.equal(web3.toAscii(cThinBlockAnchor[0]), cblockHash);
     assert.equal(web3.toAscii(cThinBlockAnchor[1]), merkleRootHash);

     await instance.addExternalCThinBlockRef(shardNum,cblockNum,"ipfs","fooUri1");
     let externalCThinBlockRef = await instance.getExternalCThinBlockRef(shardNum,cblockNum,"ipfs");
     assert.equal(externalCThinBlockRef, "fooUri1");
  })
  ,
  it("should add cBlocknum 2", async () => {
     let cblockHash = "703836587B41B5B7326E63C8AB492F61";
     let merkleRootHash = "403836587B41B5B7326E63C8AB492F61";
     let cblockNum = 2;
     assert.isFalse(await instance.cThinBlockAnchorExists(shardNum,cblockNum));

     await instance.addCThinBlockAnchor(shardNum,cblockNum, cblockHash, merkleRootHash);
     assert.isTrue(await instance.cThinBlockAnchorExists(shardNum,cblockNum));
     let cThinBlockAnchor = await instance.getCThinBlockAnchor(shardNum,cblockNum);
     assert.equal(web3.toAscii(cThinBlockAnchor[0]), cblockHash);
     assert.equal(web3.toAscii(cThinBlockAnchor[1]), merkleRootHash);

     await instance.addExternalCThinBlockRef(shardNum,cblockNum,"ipfs","fooUri1");
     await instance.addExternalCThinBlockRef(shardNum,cblockNum,"bitcoin","barUri1");

     let externalCThinBlockRef = await instance.getExternalCThinBlockRef(shardNum,cblockNum,"ipfs");
     assert.equal(externalCThinBlockRef, "fooUri1");
     externalCThinBlockRef = await instance.getExternalCThinBlockRef(shardNum,cblockNum,"bitcoin");
     assert.equal(externalCThinBlockRef, "barUri1");
  }),
  it("should add cBlocknum 3 using real hash functions", async () => {
     let cblockHash = web3.sha3("This is a test cblock");
     let merkleRootHash = web3.sha3("This is test merkle");
     let cblockNum = 3;
     assert.isFalse(await instance.cThinBlockAnchorExists(shardNum,cblockNum));

     await instance.addCThinBlockAnchor(shardNum,cblockNum, cblockHash, merkleRootHash);
     assert.isTrue(await instance.cThinBlockAnchorExists(shardNum,cblockNum));
     let cThinBlockAnchor = await instance.getCThinBlockAnchor(shardNum,cblockNum);
     assert.equal(cThinBlockAnchor[0], cblockHash);
     assert.equal(cThinBlockAnchor[1], merkleRootHash);
  })
})
