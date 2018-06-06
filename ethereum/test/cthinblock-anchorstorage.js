const CThinBlockAnchorStorage = artifacts.require("CThinBlockAnchorStorage")
contract('CThinBlockAnchorStorage test', async (accounts) => {

  it("should add cBlocknum 1", async () => {
     let instance = await CThinBlockAnchorStorage.deployed();
     let cblockHash = "703836587B41B5B7326E63C8AB492F61";
     let merkleRootHash = "403836587B41B5B7326E63C8AB492F61";
     let shardNum = 0;
     let cblockNum = 1;
     await instance.addCThinBlockAnchor(shardNum,cblockNum, cblockHash, merkleRootHash);
     let cThinBlockAnchor = await instance.getCThinBlockAnchor(shardNum,cblockNum);
     assert.equal(web3.toAscii(cThinBlockAnchor[0]), cblockHash);
     assert.equal(web3.toAscii(cThinBlockAnchor[1]), merkleRootHash);
     await instance.addExternalCThinBlockRef(shardNum,cblockNum,"ipfs","fooUri1");
     let externalCThinBlockRef = await instance.getExternalCThinBlockRef(shardNum,cblockNum,"ipfs");
     assert.equal(externalCThinBlockRef, "fooUri1");
  })
})
