pragma solidity ^0.4.4;

import './CCTrustable.sol';

contract CThinBlockAnchorStorage is CCTrustable {
    struct CThinBlockAnchor {
        bool exists;
        bytes32 cThinBlockHash;
        bytes32 merkleRootHash;
        mapping (string => string) externalCThinBlockRefs;
    }

    //governor to shardNum to blockNum to anchor mappings
    mapping (address => mapping (uint16 => mapping(uint16 => CThinBlockAnchor))) cThinBlockAnchors;

    constructor (address _registryAddr) CCTrustable(_registryAddr) public {
    // constructor
    }

    function addCThinBlockAnchor(uint16 shard, uint16 cblockNum, bytes32 _cThinBlockHash, bytes32 _merkleRootHash) public {
        //validate governor in Ecosystem contract
        address governor = msg.sender;
        require(!cThinBlockAnchorExists(shard, cblockNum));
        cThinBlockAnchors[governor][shard][cblockNum] = CThinBlockAnchor({
            cThinBlockHash : _cThinBlockHash,
            merkleRootHash : _merkleRootHash,
            exists: true
        });
    }

    function addExternalCThinBlockRef(uint16 shard, uint16 cblockNum, string externalCThinBlockRefType, string externalCThinBlockRef) public {
        address governor = msg.sender;
        require(cThinBlockAnchorExists(shard, cblockNum));
        require(bytes(cThinBlockAnchors[governor][shard][cblockNum].externalCThinBlockRefs[externalCThinBlockRefType]).length == 0);
        cThinBlockAnchors[governor][shard][cblockNum].externalCThinBlockRefs[externalCThinBlockRefType] = externalCThinBlockRef;
    }

    function cThinBlockAnchorExists(uint16 shard, uint16 cblockNum) public view returns (bool) {
        address governor = msg.sender;
        require(shard >= 0);
        require(cblockNum >= 1);
        return cThinBlockAnchors[governor][shard][cblockNum].exists;
    }

    function getCThinBlockAnchor(uint16 shard, uint16 cblockNum) public view returns (bytes32 cThinBlockHash, bytes32 merkleRootHash) {
        address governor = msg.sender;
        require(cThinBlockAnchorExists(shard, cblockNum));
        CThinBlockAnchor memory cThinBlockAnchor = cThinBlockAnchors[governor][shard][cblockNum];
        return (cThinBlockAnchor.cThinBlockHash,cThinBlockAnchor.merkleRootHash);
    }

    function getExternalCThinBlockRef(uint16 shard, uint16 cblockNum, string externalCThinBlockRefType) public view returns (string externalCThinBlockRef) {
        address governor = msg.sender;
        require(cThinBlockAnchorExists(shard, cblockNum));
        require(bytes(cThinBlockAnchors[governor][shard][cblockNum].externalCThinBlockRefs[externalCThinBlockRefType]).length != 0);
        return (cThinBlockAnchors[governor][shard][cblockNum].externalCThinBlockRefs[externalCThinBlockRefType]);
    }
}
