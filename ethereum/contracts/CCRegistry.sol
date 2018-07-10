pragma solidity ^0.4.4;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

interface ImmutableRegistry {
    function isGovernor(address _addr) external view returns (bool);
    function getGovernorDomainHash(address _addr) external view returns (bytes32);
    function isPermittedContract(address called, address caller) external view returns (bool);
    function getContractAddr(string name) external view returns (address);
}

contract CCRegistry is ImmutableRegistry, Ownable {
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
        require(bytes(domainName).length > 0);
        require(governorAddress != address(0x0));
        bytes32 domainHash = keccak256(abi.encodePacked(domainName));
        require(domainHashToGovernor[domainHash] == address(0x0));
        domainHashToGovernor[domainHash] = governorAddress;
        governorToDomainHash[governorAddress] = domainHash;
        emit GovernorRegistered(domainName, governorAddress);
    }
    /**
     * @dev Allows the current owner to add a new governor to the contract.
     * @param newGovernor The address to add to governers.
     */
    function replaceGovernorAddress(string domainName, address newGovernor) public onlyOwner {
        require(bytes(domainName).length > 0);
        require(newGovernor != address(0x0));
        bytes32 domainHash = keccak256(abi.encodePacked(domainName));
        require(domainHashToGovernor[domainHash] != address(0x0));
        address oldGovernor = domainHashToGovernor[domainHash];
        domainHashToGovernor[domainHash] = newGovernor;
        governorToDomainHash[newGovernor] = domainHash;
        delete governorToDomainHash[oldGovernor];
        emit GovernorReplaced(domainName, oldGovernor, newGovernor);
    }

    /**
     * @dev Allows the current owner to remove a governor from the contract.
     * @param domainName The domainName to remove from governers.
     */
    function deregisterGovernor(string domainName) public onlyOwner {
        require(bytes(domainName).length > 0);
        bytes32 domainHash = keccak256(abi.encodePacked(domainName));
        require(domainHashToGovernor[domainHash] != address(0x0));
        address governorAddress = domainHashToGovernor[domainHash];
        delete governorToDomainHash[governorAddress];
        delete domainHashToGovernor[domainHash];
        emit GovernorDeRegistered(domainName, governorAddress);
    }

    function registerContract(string name, address contractAddress) public onlyOwner {
        require(bytes(name).length > 0);
        require(contractAddress != address(0x0));
        bytes32 hash = keccak256(abi.encodePacked(name));
        if (nameHashToContract[hash] != address(0x0)) {
            deregisterContract(name);
        }
        nameHashToContract[hash] = contractAddress;
        contractToNameHash[contractAddress] = hash;
        emit ContractRegistered(name, contractAddress);
    }

    function deregisterContract(string name) public onlyOwner {
        require(bytes(name).length > 0);
        bytes32 hash = keccak256(abi.encodePacked(name));
        address contractAddress = nameHashToContract[hash];
        require(contractAddress != address(0x0));
        delete contractToNameHash[contractAddress];
        delete nameHashToContract[hash];
        emit ContractDeRegistered(name, contractAddress);
    }

    function addPermittedContract(string called, string caller) public onlyOwner {
        require(bytes(called).length > 0);
        require(bytes(caller).length > 0);
        bytes32 calledNameHash = keccak256(abi.encodePacked(called));
        bytes32 callerNameHash = keccak256(abi.encodePacked(caller));
        bytes32 hash = keccak256(abi.encodePacked(calledNameHash, callerNameHash));
        contractPerms[hash] = true;
        emit ContractPermissionGranted(called, caller);
    }

    function removePermittedContract(string called, string caller) public onlyOwner {
        require(bytes(called).length > 0);
        require(bytes(caller).length > 0);
        bytes32 calledNameHash = keccak256(abi.encodePacked(called));
        bytes32 callerNameHash = keccak256(abi.encodePacked(caller));
        bytes32 hash = keccak256(abi.encodePacked(calledNameHash, callerNameHash));
        delete contractPerms[hash];
        emit ContractPermissionRevoked(called, caller);
    }

    function getContractAddr(string name) external view returns (address) {
        require(bytes(name).length > 0);
        bytes32 hash = keccak256(abi.encodePacked(name));
        require(nameHashToContract[hash] != address(0x0));
        return nameHashToContract[hash];
    }

    function isPermittedContract(address called, address caller) external view returns (bool) {
        require(called != address(0x0));
        require(caller != address(0x0));
        bytes32 calledNameHash = contractToNameHash[called];
        bytes32 callerNameHash = contractToNameHash[caller];
        bytes32 hash = keccak256(abi.encodePacked(calledNameHash, callerNameHash));
        return contractPerms[hash] == true;
    }

    function isGovernor(address _addr) external view returns (bool) {
        require(_addr != address(0x0));
        bytes32 domainHash = governorToDomainHash[_addr];
        return domainHash[0] != 0;
    }

    function getGovernorDomainHash(address _addr) external view returns (bytes32) {
        require(_addr != address(0x0));
        bytes32 domainHash = governorToDomainHash[_addr];
        require(domainHash[0] != 0);
        return governorToDomainHash[_addr];
    }

}