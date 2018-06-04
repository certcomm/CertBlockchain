pragma solidity ^0.4.4;


contract CThinBlockAnchorStorage {
    struct CThinBlockAnchor {
        bool exists;
        bytes32 cThinBlockHash;
        bytes32 merkleRootHash;
        mapping (string => string) externalAnchorRefs;
    }

    //governor to shard to anchor mappings
    mapping (address => mapping (uint16 => mapping(uint16 => CThinBlockAnchor))) cThinBlockAnchors;

    constructor () public {
    // constructor
    }

    function addCThinBlockAnchor(uint16 shard, uint16 cblockNum, bytes32 _cThinBlockHash, bytes32 _merkleRootHash) public {
        address governor = msg.sender;
        require(shard >= 0);
        require(cblockNum > 1);
        require(cThinBlockAnchors[governor][shard][cblockNum].exists);
        cThinBlockAnchors[governor][shard][cblockNum] = CThinBlockAnchor({
            cThinBlockHash : _cThinBlockHash,
            merkleRootHash : _merkleRootHash,
            exists: true
        });
    }

    function addExternalAnchorRef(uint16 shard, uint16 cblockNum, string externalAnchorType, string externalAnchorRef) public {
        address governor = msg.sender;
        require(shard >= 0);
        require(cblockNum > 1);
        require(!cThinBlockAnchors[governor][shard][cblockNum].exists);
        require(bytes(cThinBlockAnchors[governor][shard][cblockNum].externalAnchorRefs[externalAnchorType]).length == 0);
        cThinBlockAnchors[governor][shard][cblockNum].externalAnchorRefs[externalAnchorType] = externalAnchorRef;
    }

    function getCThinBlockAnchor(uint16 shard, uint16 cblockNum) public returns (bytes32 cThinBlockHash, bytes32 merkleRootHash) {
        address governor = msg.sender;
        require(!cThinBlockAnchors[governor][shard][cblockNum].exists);
        CThinBlockAnchor memory cThinBlockAnchor = cThinBlockAnchors[governor][shard][cblockNum];
        return (cThinBlockAnchor.cThinBlockHash,cThinBlockAnchor.merkleRootHash);
    }

    function getExternalAnchorRef(uint16 shard, uint16 cblockNum, string externalAnchorType) public returns (string externalAnchorRef) {
        address governor = msg.sender;
        require(!cThinBlockAnchors[governor][shard][cblockNum].exists);
        require(bytes(cThinBlockAnchors[governor][shard][cblockNum].externalAnchorRefs[externalAnchorType]).length == 0);
        CThinBlockAnchor memory cThinBlockAnchor = cThinBlockAnchors[governor][shard][cblockNum];
        return (cThinBlockAnchors[governor][shard][cblockNum].externalAnchorRefs[externalAnchorType]);
    }
}
