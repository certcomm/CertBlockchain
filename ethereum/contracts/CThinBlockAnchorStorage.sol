pragma solidity ^0.4.4;

import './CCTrustable.sol';

contract CThinBlockAnchorStorage is CCTrustable {
    struct CThinBlockAnchor {
        bool exists;
        bytes32 cThinBlockHash;
        bytes32 merkleRootHash;
        mapping (bytes32 => string) externalCThinBlockRefs;
    }

    //governor domain hash to shardNum to blockNum to anchor mappings
    mapping (bytes32 => mapping (uint16 => mapping(uint16 => CThinBlockAnchor))) cThinBlockAnchors;

    constructor (address _registryAddr) CCTrustable(_registryAddr) public {
    // constructor
    }

    function addCThinBlockAnchor(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum, bytes32 _cThinBlockHash, bytes32 _merkleRootHash) public onlyOwnerOrPermittedContracts {
        require(!cThinBlockAnchorExists(governorDomainHash, shard, cblockNum));
        cThinBlockAnchors[governorDomainHash][shard][cblockNum] = CThinBlockAnchor({
            cThinBlockHash : _cThinBlockHash,
            merkleRootHash : _merkleRootHash,
            exists: true
        });
    }

    function addExternalCThinBlockRef(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum, string externalCThinBlockRefType, string externalCThinBlockRef) public onlyOwnerOrPermittedContracts {
        require(cThinBlockAnchorExists(governorDomainHash, shard, cblockNum));
        bytes32 refTypeHash = keccak256(externalCThinBlockRefType);
        require(bytes(cThinBlockAnchors[governorDomainHash][shard][cblockNum].externalCThinBlockRefs[refTypeHash]).length == 0);
        cThinBlockAnchors[governorDomainHash][shard][cblockNum].externalCThinBlockRefs[refTypeHash] = externalCThinBlockRef;
    }

    function cThinBlockAnchorExists(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum) public onlyOwnerOrPermittedContracts view returns (bool)  {
        require(shard >= 0);
        require(cblockNum >= 1);
        return cThinBlockAnchors[governorDomainHash][shard][cblockNum].exists;
    }

    function getCThinBlockAnchor(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum) public onlyOwnerOrPermittedContracts view returns (bytes32 cThinBlockHash, bytes32 merkleRootHash) {
        require(cThinBlockAnchorExists(governorDomainHash, shard, cblockNum));
        CThinBlockAnchor memory cThinBlockAnchor = cThinBlockAnchors[governorDomainHash][shard][cblockNum];
        return (cThinBlockAnchor.cThinBlockHash,cThinBlockAnchor.merkleRootHash);
    }

    function getExternalCThinBlockRef(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum, string externalCThinBlockRefType) public onlyOwnerOrPermittedContracts view returns (string externalCThinBlockRef) {
        require(cThinBlockAnchorExists(governorDomainHash, shard, cblockNum));
        bytes32 refTypeHash = keccak256(externalCThinBlockRefType);
        require(bytes(cThinBlockAnchors[governorDomainHash][shard][cblockNum].externalCThinBlockRefs[refTypeHash]).length != 0);
        return (cThinBlockAnchors[governorDomainHash][shard][cblockNum].externalCThinBlockRefs[refTypeHash]);
    }
}
