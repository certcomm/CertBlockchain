pragma solidity 0.4.24;

import './CCTrustable.sol';
import './CThinBlockAnchorStorage.sol';

contract CThinBlockAnchorOps is CCTrustable {
    event CThinBlockAnchorCreated(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum);

    constructor (address _registryAddr) CCTrustable(_registryAddr) public {
    // constructor
    }

    function getCThinBlockAnchorStorage() private view returns (ICThinBlockAnchorStorage) {
        return ICThinBlockAnchorStorage(registry.getContractAddr("CThinBlockAnchorStorage"));
    }

    function addCThinBlockAnchor(uint16 shard, uint16 cblockNum, bytes32 cThinBlockHash, bytes32 merkleRootHash) public onlyGovernor  {
        bytes32 governorDomainHash = registry.getGovernorDomainHash(msg.sender);
        getCThinBlockAnchorStorage().addCThinBlockAnchor(governorDomainHash, shard, cblockNum, cThinBlockHash, merkleRootHash);
        emit CThinBlockAnchorCreated(governorDomainHash, shard, cblockNum);
    }

    function addExternalCThinBlockRef(uint16 shard, uint16 cblockNum, string externalCThinBlockRefType, string externalCThinBlockRef) public onlyGovernor {
        bytes32 governorDomainHash = registry.getGovernorDomainHash(msg.sender);
        getCThinBlockAnchorStorage().addExternalCThinBlockRef(governorDomainHash, shard, cblockNum, externalCThinBlockRefType, externalCThinBlockRef);
    }

    function cThinBlockAnchorExists(uint16 shard, uint16 cblockNum) public onlyGovernor view returns (bool)  {
        bytes32 governorDomainHash = registry.getGovernorDomainHash(msg.sender);
        return getCThinBlockAnchorStorage().cThinBlockAnchorExists(governorDomainHash, shard, cblockNum);
    }

    function getCThinBlockAnchor(uint16 shard, uint16 cblockNum) public onlyGovernor view returns (bytes32 cThinBlockHash, bytes32 merkleRootHash) {
        bytes32 governorDomainHash = registry.getGovernorDomainHash(msg.sender);
        return getCThinBlockAnchorStorage().getCThinBlockAnchor(governorDomainHash, shard, cblockNum);
    }

    function getExternalCThinBlockRef(uint16 shard, uint16 cblockNum, string externalCThinBlockRefType) public onlyGovernor view returns (string externalCThinBlockRef) {
        bytes32 governorDomainHash = registry.getGovernorDomainHash(msg.sender);
        return getCThinBlockAnchorStorage().getExternalCThinBlockRef(governorDomainHash, shard, cblockNum, externalCThinBlockRefType);
    }
}
