pragma solidity ^0.4.4;


import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import './CCRegistry.sol';


contract CCTrustable is Ownable {
    ImmutableRegistry registry;

    constructor (address _registryAddr) public {
        require(_registryAddr != address(0x0));
        registry = ImmutableRegistry(_registryAddr);
    }

    function isOwner() private view returns (bool) {
        return msg.sender == owner;
    }

    function isGovernor() private view returns (bool) {
        return registry.isGovernor(msg.sender);
    }

    function isPermittedContract() private view returns (bool) {
        return registry.isPermittedContract(address(this), msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the governor.
     */
    modifier onlyGovernor() {
        require(isGovernor());
        _;
    }

    /**
     * @dev Throws if called by anyone other than the permitted contracts.
     */
    modifier onlyPermittedContracts() {
        require(isPermittedContract());
        _;
    }

    /**
     * @dev Throws if called by anyone other than owner, governor or permitted contracts.
     */
    modifier onlyOwnerOrGovernorOrPermittedContracts() {
        require(isOwner() || isGovernor() || isPermittedContract());
        _;
    }

    /**
     * @dev Throws if called by anyone other than the owner or permitted contracts.
     */
    modifier onlyOwnerOrPermittedContracts() {
        require(isOwner() || isPermittedContract());
        _;
    }
    /**
     * @dev Throws if called by anyone other than the owner or governor.
     */
    modifier onlyOwnerOrGovernor() {
        require(isOwner() || isGovernor() );
        _;
    }
}


