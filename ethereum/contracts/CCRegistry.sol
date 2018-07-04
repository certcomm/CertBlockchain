pragma solidity ^0.4.4;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract CCRegistry is Ownable {
    //1:1 mapping of contract name to address
    mapping(bytes32 => address) nameHashToContract;
    //1:1 mapping of contract address to name
    mapping(address => bytes32) contractToNameHash;
    //1:1 mapping of hash(called contractName, caller contract name)
    mapping(bytes32 => bool) contractPerms;

    // 1:1 map of governor address to domain name hash, this allows us to swap governor address in case of Private key loss
    mapping(address => bytes32) governorToDomainHash;

    // 1:1 map of domain name hash to governor address
    mapping(bytes32 => address) domainHashToGovernor;

    address ccOwner;

    event GovernorRegistered(string domainName, address indexed governorAddress);
    event GovernorDeRegistered(string domainName, address indexed governorAddress);
    event GovernorReplaced(string domainName, address indexed oldGovernorAddress, address indexed newGovernorAddress);
    event ContractPermissionGranted(string called, string caller);
    event ContractPermissionRevoked(string called, string caller);
    event ContractRegistered(string name, address indexed contractAddress);
    event ContractDeRegistered(string name, address indexed contractAddress);

    constructor () public {
        ccOwner = msg.sender;
    }

    /**
     * @dev Allows the current owner to add a new governor to the contract.
     * @param governorAddress The address to add to governers.
     */
    function registerGovernor(string domainName, address governorAddress) public onlyOwner {
        bytes32 domainHash = keccak256(domainName);
        require(domainHashToGovernor[domainHash] == address(0x0));
        domainHashToGovernor[domainHash] = governorAddress;
        governorToDomainHash[governorAddress] = domainHash;
        GovernorRegistered(domainName, governorAddress);
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
        GovernorReplaced(domainName, oldGovernor, newGovernor);
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
        GovernorDeRegistered(domainName, governorAddress);
    }

    function registerContract(string name, address contractAddress) public onlyOwner {
        require(bytes(name).length > 0);
        require(contractAddress != address(0x0));
        bytes32 hash = keccak256(name);
        if (nameHashToContract[hash] != address(0x0)) {
            deregisterContract(name);
        }
        nameHashToContract[hash] = contractAddress;
        contractToNameHash[contractAddress] = hash;
        ContractRegistered(name, contractAddress);
    }

    function deregisterContract(string name) public onlyOwner {
        require(bytes(name).length > 0);
        bytes32 hash = keccak256(name);
        address contractAddress = nameHashToContract[hash];
        require(contractAddress != address(0x0));
        delete contractToNameHash[contractAddress];
        delete nameHashToContract[hash];
        ContractDeRegistered(name, contractAddress);
    }

    function getContractAddr(string name) public view returns (address) {
        require(bytes(name).length > 0);
        bytes32 hash = keccak256(name);
        require(nameHashToContract[hash] != address(0x0));
        return nameHashToContract[hash];
    }

    function addPermittedContract(string called, string caller) public onlyOwner {
        require(bytes(called).length > 0);
        require(bytes(caller).length > 0);
        bytes32 calledNameHash = keccak256(called);
        bytes32 callerNameHash = keccak256(caller);
        bytes32 hash = keccak256(abi.encodePacked(calledNameHash, callerNameHash));
        contractPerms[hash] = true;
        ContractPermissionGranted(called, caller);
    }

    function removePermittedContract(string called, string caller) public onlyOwner {
        require(bytes(called).length > 0);
        require(bytes(caller).length > 0);
        bytes32 calledNameHash = keccak256(called);
        bytes32 callerNameHash = keccak256(caller);
        bytes32 hash = keccak256(abi.encodePacked(calledNameHash, callerNameHash));
        delete contractPerms[hash];
        ContractPermissionRevoked(called, caller);
    }

    function isPermittedContract(address called, address caller) public view returns (bool) {
        bytes32 calledNameHash = contractToNameHash[called];
        bytes32 callerNameHash = contractToNameHash[caller];
        bytes32 hash = keccak256(abi.encodePacked(calledNameHash, callerNameHash));
        return contractPerms[hash] == true;
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