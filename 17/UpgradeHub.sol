// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UpgradeHub {

    address public owner;
    address public implementation;

    mapping(address => uint) public subscriptionExpiry;

    constructor(address _implementation) {
        owner = msg.sender;
        implementation = _implementation;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function upgrade(address newImplementation) public onlyOwner {
        implementation = newImplementation;
    }

    fallback() external payable {
        address impl = implementation;
        require(impl != address(0));

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}