// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VerificationOracle is ChainlinkClient, Ownable {
    using Chainlink for Chainlink.Request;

    address public ccipRouter;
    bytes32 private jobId;
    uint256 private fee;

    uint256 public response;
    
    // For testing purposes
    bool public mockFulfillment;

    event RequestFulfilled(bytes32 indexed requestId, uint256 indexed data);
    event CrossChainVerificationRequest(uint256 tokenId, address requester, string destinationChain);

    constructor(address _ccipRouter, address _linkToken) {
        _setChainlinkToken(_linkToken);
        ccipRouter = _ccipRouter;
        jobId = "8ced832954544a3c98543c94a51d6a8d";
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        mockFulfillment = false;
    }

    function requestCrossChainIdentityVerification(uint256 tokenId, string memory did, string memory destinationChain) public {
        if (mockFulfillment) {
            emit CrossChainVerificationRequest(tokenId, msg.sender, destinationChain);
        } else {
            Chainlink.Request memory req = _buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
            req._add("did", did);
            req._add("destinationChain", destinationChain);
            _sendChainlinkRequestTo(ccipRouter, req, fee);
            emit CrossChainVerificationRequest(tokenId, msg.sender, destinationChain);
        }
    }

    function fulfill(bytes32 _requestId, uint256 _identityData) public recordChainlinkFulfillment(_requestId) {
        response = _identityData;
        emit RequestFulfilled(_requestId, _identityData);
    }

    // For testing purposes
    function mockFulfill(bytes32 _requestId, uint256 _identityData) public {
        require(mockFulfillment, "Mock fulfillment is not enabled");
        response = _identityData;
        emit RequestFulfilled(_requestId, _identityData);
    }

    function setCcipRouter(address _ccipRouter) public onlyOwner {
        ccipRouter = _ccipRouter;
    }

    function setJobId(bytes32 _jobId) public onlyOwner {
        jobId = _jobId;
    }

    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    // For testing purposes
    function setMockFulfillment(bool _mockFulfillment) public onlyOwner {
        mockFulfillment = _mockFulfillment;
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(_chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    }
}