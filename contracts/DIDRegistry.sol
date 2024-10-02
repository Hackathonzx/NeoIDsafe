// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DIDRegistry is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _didCounter;

    struct DID {
        uint256 id;
        address owner;
        string didURI;
    }

    mapping(uint256 => DID) public dids;
    mapping(address => uint256) public addressToDID;

    event DIDRegistered(address indexed owner, uint256 didId, string didURI);

    function registerDID(string memory didURI) external {
        require(addressToDID[msg.sender] == 0, "DID already registered");

        uint256 newDIDId = _didCounter.current();
        _didCounter.increment();

        dids[newDIDId] = DID({
            id: newDIDId,
            owner: msg.sender,
            didURI: didURI
        });

        addressToDID[msg.sender] = newDIDId;

        emit DIDRegistered(msg.sender, newDIDId, didURI);
    }

    function getDID(uint256 didId) external view returns (DID memory) {
        require(dids[didId].id == didId, "DID not found");
        return dids[didId];
    }
}