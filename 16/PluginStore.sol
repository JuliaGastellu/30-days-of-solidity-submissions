// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore {

    struct Profile {
        string name;
        string avatar;
    }

    mapping(address => Profile) public profiles;
    mapping(address => address[]) public activePlugins;

    function setProfile(string calldata _name, string calldata _avatar) external {
        profiles[msg.sender] = Profile(_name, _avatar);
    }

    function activatePlugin(address plugin) external {
        activePlugins[msg.sender].push(plugin);
    }

    function runPlugin(address plugin, bytes calldata data) external {
        (bool success, ) = plugin.delegatecall(data);
        require(success);
    }

    function getPlugins(address user) external view returns(address[] memory) {
        return activePlugins[user];
    }
}