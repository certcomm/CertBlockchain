pragma solidity ^0.4.4;

import './CCTrustable.sol';

contract CThinBlockAnchorStorage is CCTrustable {
    struct CThinBlockAnchor {
        bool exists;
        bytes32 cThinBlockHash;
        bytes32 merkleRootHash;
        mapping (string => string) externalCThinBlockRefs;
    }

    //governor domain hash to shardNum to blockNum to anchor mappings
    mapping (bytes32 => mapping (uint16 => mapping(uint16 => CThinBlockAnchor))) cThinBlockAnchors;

    constructor (address _registryAddr) CCTrustable(_registryAddr) public {
    // constructor
    }

    function addCThinBlockAnchor(uint16 shard, uint16 cblockNum, bytes32 _cThinBlockHash, bytes32 _merkleRootHash) public onlyGovernor {
        bytes32 governorDomainHash = registry.getGovernorDomainHash(msg.sender);
        require(!cThinBlockAnchorExists(shard, cblockNum));
        cThinBlockAnchors[governorDomainHash][shard][cblockNum] = CThinBlockAnchor({
            cThinBlockHash : _cThinBlockHash,
            merkleRootHash : _merkleRootHash,
            exists: true
        });
    }

    function addExternalCThinBlockRef(uint16 shard, uint16 cblockNum, string externalCThinBlockRefType, string externalCThinBlockRef) public onlyGovernor {
        require(cThinBlockAnchorExists(shard, cblockNum));
        bytes32 governorDomainHash = registry.getGovernorDomainHash(msg.sender);
        require(bytes(cThinBlockAnchors[governorDomainHash][shard][cblockNum].externalCThinBlockRefs[externalCThinBlockRefType]).length == 0);
        cThinBlockAnchors[governorDomainHash][shard][cblockNum].externalCThinBlockRefs[externalCThinBlockRefType] = externalCThinBlockRef;
    }

    function cThinBlockAnchorExists(uint16 shard, uint16 cblockNum) public onlyGovernor view returns (bool)  {
        require(shard >= 0);
        require(cblockNum >= 1);
        bytes32 governorDomainHash = registry.getGovernorDomainHash(msg.sender);
        return cThinBlockAnchors[governorDomainHash][shard][cblockNum].exists;
    }

    function getCThinBlockAnchor(uint16 shard, uint16 cblockNum) public onlyGovernor view returns (bytes32 cThinBlockHash, bytes32 merkleRootHash) {
        require(cThinBlockAnchorExists(shard, cblockNum));
        bytes32 governorDomainHash = registry.getGovernorDomainHash(msg.sender);
        CThinBlockAnchor memory cThinBlockAnchor = cThinBlockAnchors[governorDomainHash][shard][cblockNum];
        return (cThinBlockAnchor.cThinBlockHash,cThinBlockAnchor.merkleRootHash);
    }

    function getExternalCThinBlockRef(uint16 shard, uint16 cblockNum, string externalCThinBlockRefType) public onlyGovernor view returns (string externalCThinBlockRef) {
        require(cThinBlockAnchorExists(shard, cblockNum));
        bytes32 governorDomainHash = registry.getGovernorDomainHash(msg.sender);
        require(bytes(cThinBlockAnchors[governorDomainHash][shard][cblockNum].externalCThinBlockRefs[externalCThinBlockRefType]).length != 0);
        return (cThinBlockAnchors[governorDomainHash][shard][cblockNum].externalCThinBlockRefs[externalCThinBlockRefType]);
    }
}
