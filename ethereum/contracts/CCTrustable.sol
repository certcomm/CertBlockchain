pragma solidity 0.4.24;


import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import './CCRegistry.sol';


contract CCTrustable is Ownable {
    address internal registryAddr;

    function injectRegistry(address _registryAddr) public onlyOwner {
        require(_registryAddr != address(0x0));
        registryAddr = _registryAddr;
    }

    function getRegistry() internal view returns (ImmutableRegistry) {
        return ImmutableRegistry(registryAddr);
    }

    function isOwner() private view returns (bool) {
        return msg.sender == owner;
    }

    function isGovernor() private view returns (bool) {
        return getRegistry().isGovernor(msg.sender);
    }

    function isPermittedContract() private view returns (bool) {
        return getRegistry().isPermittedContract(address(this), msg.sender);
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


