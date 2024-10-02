
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CredentialNFT is ERC721, Ownable {
    using Counters for Counters.Counter;  
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => string) public tokenIdToMetadata;  // Store metadata for credentials

    event CredentialIssued(address indexed to, uint256 tokenId);
    event IdentityVerifiedCrossChain(address indexed user, uint256 tokenId, string chain);

    constructor() ERC721("CredentialNFT", "CRDNTL") {}

    function issueCredentialWithMetadata(address to, string memory metadata) external onlyOwner {
        uint256 newTokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _mint(to, newTokenId);
        tokenIdToMetadata[newTokenId] = metadata;  // Store metadata
        emit CredentialIssued(to, newTokenId);
    }

    function getCredentialMetadata(uint256 tokenId) public view returns (string memory) {
        return tokenIdToMetadata[tokenId];
    }

    function emitCrossChainVerificationEvent(uint256 tokenId, string memory chain) external onlyOwner {
        emit IdentityVerifiedCrossChain(ownerOf(tokenId), tokenId, chain);
    }

    function burnCredential(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the credential owner");
        _burn(tokenId);
    }
}
