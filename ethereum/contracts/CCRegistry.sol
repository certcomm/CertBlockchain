pragma solidity ^0.4.4;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract CCRegistry is Ownable {
    mapping (string => address) contractAddresses;

    mapping (address => bool) trustedContracts;
    // map of governors
    mapping (address => bool) public governors;

    address certcommOwner;

    constructor () public {
        certcommOwner = msg.sender;
    }

    /**
     * @dev Allows the current owner to add a new governor to the contract.
     * @param newGovernor The address to add to governers.
     */
    function registerGovernor(address newGovernor) public onlyOwner {
        require(!governors[newGovernor]);
        governors[newGovernor] = true;
    }

    /**
     * @dev Allows the current owner to remove a governor from the contract.
     * @param governorToRemove The address to remove from governers.
     */
    function deregisterGovernor(address governorToRemove) public onlyOwner {
        require(governors[governorToRemove]);
        delete governors[governorToRemove];
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
        return governors[_addr] == true;
    }

}