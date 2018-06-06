const CThinBlockAnchorStorage = artifacts.require("CThinBlockAnchorStorage")
const shardNum = 0;
contract('CThinBlockAnchorStorage test', async (accounts) => {
  it("should add cBlocknum 1", async () => {
     let instance = await CThinBlockAnchorStorage.deployed();
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
  }),
  it("should add cBlocknum 2", async () => {
     let instance = await CThinBlockAnchorStorage.deployed();
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
  })
})
