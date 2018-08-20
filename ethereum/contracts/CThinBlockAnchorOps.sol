pragma solidity 0.4.24;

import './CCTrustable.sol';
import './CThinBlockAnchorStorage.sol';

contract CThinBlockAnchorOps is CCTrustable {
    event CThinBlockAnchorCreated(bytes32 governorDomainHash, uint16 shard, uint16 cblockNum);

    function getCThinBlockAnchorStorage() private view returns (ICThinBlockAnchorStorage) {
        return ICThinBlockAnchorStorage(getRegistry().getContractAddr("CThinBlockAnchorStorage"));
    }

    function calculateGovernorDomainHash(string governorDomainName) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(governorDomainName));
    }

    function addCThinBlockAnchor(uint16 shard, uint16 cblockNum, string cThinBlockHash, string merkleRootHash) public onlyGovernor  {
        bytes32 governorDomainHash = getRegistry().getGovernorDomainHash(msg.sender);
        getCThinBlockAnchorStorage().addCThinBlockAnchor(governorDomainHash, shard, cblockNum, cThinBlockHash, merkleRootHash);
        emit CThinBlockAnchorCreated(governorDomainHash, shard, cblockNum);
    }

    function addExternalCThinBlockRef(uint16 shard, uint16 cblockNum, string externalCThinBlockRefType, string externalCThinBlockRef) public onlyGovernor {
        bytes32 governorDomainHash = getRegistry().getGovernorDomainHash(msg.sender);
        getCThinBlockAnchorStorage().addExternalCThinBlockRef(governorDomainHash, shard, cblockNum, externalCThinBlockRefType, externalCThinBlockRef);
    }

    function cThinBlockAnchorExists(string governorDomainName, uint16 shard, uint16 cblockNum) public view returns (bool)  {
        bytes32 governorDomainHash = calculateGovernorDomainHash(governorDomainName);
        return getCThinBlockAnchorStorage().cThinBlockAnchorExists(governorDomainHash, shard, cblockNum);
    }

    function getCThinBlockAnchor(string governorDomainName, uint16 shard, uint16 cblockNum) public view returns (string cThinBlockHash, string merkleRootHash) {
        bytes32 governorDomainHash = calculateGovernorDomainHash(governorDomainName);
        return getCThinBlockAnchorStorage().getCThinBlockAnchor(governorDomainHash, shard, cblockNum);
    }

    function getExternalCThinBlockRef(string governorDomainName, uint16 shard, uint16 cblockNum, string externalCThinBlockRefType) public view returns (string externalCThinBlockRef) {
        bytes32 governorDomainHash = calculateGovernorDomainHash(governorDomainName);
        return getCThinBlockAnchorStorage().getExternalCThinBlockRef(governorDomainHash, shard, cblockNum, externalCThinBlockRefType);
    }
}
