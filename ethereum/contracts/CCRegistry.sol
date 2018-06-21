pragma solidity ^0.4.4;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract CCRegistry is Ownable {
    mapping (string => address) contractAddresses;

    mapping (address => bool) trustedContracts;
    // 1:1 map of governor address to domain name hash, this allows us to swap governor address in case of Private key loss
    mapping (address => bytes32) governorToDomainHash;

    // 1:1 map of domain name hash to governor address
    mapping (bytes32 => address) domainHashToGovernor;

    address certcommOwner;

    constructor () public {
        certcommOwner = msg.sender;
    }

    /**
     * @dev Allows the current owner to add a new governor to the contract.
     * @param newGovernor The address to add to governers.
     */
    function registerGovernor(string domainName, address newGovernor) public onlyOwner {
        bytes32 domainHash = keccak256(domainName);
        require(domainHashToGovernor[domainHash] == address(0x0));
        domainHashToGovernor[domainHash] = newGovernor;
        governorToDomainHash[newGovernor] = domainHash;
    }
    /**
     * @dev Allows the current owner to add a new governor to the contract.
     * @param newGovernor The address to add to governers.
     */
    function replaceGovernorAddress(string domainName, address newGovernor) public onlyOwner {
        bytes32 domainHash = keccak256(domainName);
        require(domainHashToGovernor[domainHash] != address(0x0));
        address oldGovernor = domainHashToGovernor[domainHash];
        domainHashToGovernor[domainHash] = newGovernor;
        governorToDomainHash[newGovernor] = domainHash;
        delete governorToDomainHash[oldGovernor];
    }

    /**
     * @dev Allows the current owner to remove a governor from the contract.
     * @param domainName The domainName to remove from governers.
     */
    function deregisterGovernor(string domainName) public onlyOwner {
        bytes32 domainHash = keccak256(domainName);
        require(domainHashToGovernor[domainHash] != address(0x0));
        address governorAddress = domainHashToGovernor[domainHash];
        delete governorToDomainHash[governorAddress];
        delete domainHashToGovernor[domainHash];
    }

    function registerContract(string _contractName, address _contractAddr) public onlyOwner {
        require(_contractAddr != address(0x0));
        contractAddresses[_contractName] = _contractAddr;
        trustedContracts[_contractAddr] = true;
    }

    function deregisterContract(string _contractName) public onlyOwner {
        require(contractAddresses[_contractName] != address(0x0));
        delete trustedContracts[contractAddresses[_contractName]];
        delete contractAddresses[_contractName];
    }

    function getContractAddr(string _contractName) public view returns (address) {
        require(contractAddresses[_contractName] != address(0x0));
        return contractAddresses[_contractName];
    }

    function isTrustedContract(address _addr) public view returns (bool) {
        return trustedContracts[_addr] == true;
    }

    function isGovernor(address _addr) public view returns (bool) {
        bytes32 domainHash = governorToDomainHash[_addr];
        return domainHash[0] != 0;
    }

    function getGovernorDomainHash(address _addr) public view returns (bytes32) {
        bytes32 domainHash = governorToDomainHash[_addr];
        require(domainHash[0] != 0);
        return governorToDomainHash[_addr];
    }

}