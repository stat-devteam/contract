// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title TokenRegistry
/// @notice Maintains the current token contract address, allowing upgrades.
/// @dev Only the contract owner can update the token address or transfer ownership.
contract TokenRegistry {
    address public tokenAddress; // Centralized token address
    address public owner;        // Owner of the registry

    event TokenUpdated(address indexed oldToken, address indexed newToken);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    /// @notice Initializes the contract with the initial token address.
    /// @param initialTokenAddress Address of the initial token contract.
    constructor(address initialTokenAddress) {
        owner = msg.sender;
        tokenAddress = initialTokenAddress; // Set initial token address
    }

    /// @notice Transfers ownership of the registry to a new address.
    /// @param newOwner The address of the new owner.
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid owner address");
        owner = newOwner;
    }

    /// @notice Updates the token contract address.
    /// @param newTokenAddress The address of the new token contract.
    function updateToken(address newTokenAddress) external onlyOwner {
        require(newTokenAddress != address(0), "Invalid token address");

        uint256 codeSize;
        assembly { codeSize := extcodesize(newTokenAddress) }
        require(codeSize > 0, "New token must be a contract");

        emit TokenUpdated(tokenAddress, newTokenAddress);

        tokenAddress = newTokenAddress; // Update the token address
    }

    /// @notice Returns the currently registered token address.
    /// @return The current token contract address.
    function getToken() public view returns (address) {
        return tokenAddress;
    }
}