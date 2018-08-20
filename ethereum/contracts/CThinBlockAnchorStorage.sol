pragma solidity 0.4.24;

import './CCTrustable.sol';

interface ICThinBlockAnchorStorage {
    function addCThinBlockAnchor(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum, string _cThinBlockHash, string _merkleRootHash) external;

    function addExternalCThinBlockRef(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum, string externalCThinBlockRefType, string externalCThinBlockRef) external;

    function cThinBlockAnchorExists(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum) external view returns (bool);

    function getCThinBlockAnchor(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum) external view returns (string cThinBlockHash, string merkleRootHash);

    function getExternalCThinBlockRef(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum, string externalCThinBlockRefType) external view returns (string externalCThinBlockRef);
}

contract CThinBlockAnchorStorage is ICThinBlockAnchorStorage, CCTrustable {
    struct CThinBlockAnchor {
        bool exists;
        string cThinBlockHash;
        string merkleRootHash;
        mapping(bytes32 => string) externalCThinBlockRefs;
    }

    //governor domain hash to shardNum to blockNum to anchor mappings
    mapping(bytes32 => mapping(uint16 => mapping(uint16 => CThinBlockAnchor))) private cThinBlockAnchors;

    function addCThinBlockAnchor(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum, string _cThinBlockHash, string _merkleRootHash) external onlyOwnerOrPermittedContracts {
        require(!_cThinBlockAnchorExists(governorDomainHash, shard, cblockNum));
        cThinBlockAnchors[governorDomainHash][shard][cblockNum] = CThinBlockAnchor({
            cThinBlockHash : _cThinBlockHash,
            merkleRootHash : _merkleRootHash,
            exists : true
            });
    }

    function addExternalCThinBlockRef(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum, string externalCThinBlockRefType, string externalCThinBlockRef) external onlyOwnerOrPermittedContracts {
        require(_cThinBlockAnchorExists(governorDomainHash, shard, cblockNum));
        bytes32 refTypeHash = keccak256(abi.encodePacked(externalCThinBlockRefType));
        require(bytes(cThinBlockAnchors[governorDomainHash][shard][cblockNum].externalCThinBlockRefs[refTypeHash]).length == 0);
        cThinBlockAnchors[governorDomainHash][shard][cblockNum].externalCThinBlockRefs[refTypeHash] = externalCThinBlockRef;
    }

    function _cThinBlockAnchorExists(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum) private onlyOwnerOrPermittedContracts view returns (bool)  {
        require(shard >= 0);
        require(cblockNum >= 1);
        return cThinBlockAnchors[governorDomainHash][shard][cblockNum].exists;
    }

    function cThinBlockAnchorExists(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum) external onlyOwnerOrPermittedContracts view returns (bool)  {
        return _cThinBlockAnchorExists(governorDomainHash, shard, cblockNum);
    }

    function getCThinBlockAnchor(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum) external onlyOwnerOrPermittedContracts view returns (string cThinBlockHash, string merkleRootHash) {
        require(_cThinBlockAnchorExists(governorDomainHash, shard, cblockNum));
        CThinBlockAnchor memory cThinBlockAnchor = cThinBlockAnchors[governorDomainHash][shard][cblockNum];
        return (cThinBlockAnchor.cThinBlockHash, cThinBlockAnchor.merkleRootHash);
    }

    function getExternalCThinBlockRef(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum, string externalCThinBlockRefType) external onlyOwnerOrPermittedContracts view returns (string externalCThinBlockRef) {
        require(_cThinBlockAnchorExists(governorDomainHash, shard, cblockNum));
        bytes32 refTypeHash = keccak256(abi.encodePacked(externalCThinBlockRefType));
        require(bytes(cThinBlockAnchors[governorDomainHash][shard][cblockNum].externalCThinBlockRefs[refTypeHash]).length != 0);
        return (cThinBlockAnchors[governorDomainHash][shard][cblockNum].externalCThinBlockRefs[refTypeHash]);
    }
}
