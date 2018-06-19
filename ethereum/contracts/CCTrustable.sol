pragma solidity ^0.4.4;


import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import './CCRegistry.sol';


contract CCTrustable is Ownable {
    CCRegistry registry;

    constructor (address _registryAddr) {
        require(_registryAddr != address(0x0));
        registry = CCRegistry(_registryAddr);
    }
    /**
     * @dev Throws if called by any account other than the governor.
     */
    modifier onlyGovernor() {
        require(registry.isGovernor(msg.sender));
        _;
    }

    /**
     * @dev Throws if called by any account other than the trusted contract.
     */
    modifier onlyTrustedContract() {
        require(registry.isTrustedContract(msg.sender));
        _;
    }
}


