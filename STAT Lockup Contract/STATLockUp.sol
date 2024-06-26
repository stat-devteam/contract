// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/// @title STATLockUp
/// @notice This contract allows users to lock up STAT tokens for a specified duration.
/// @dev Implements token lockup functionality with EIP-712 signature verification.
contract STATLockUp is ReentrancyGuard, Ownable, Pausable {
    using ECDSA for bytes32;

    IERC20 public token;

    mapping(address => uint256) public lockedUpAmounts; // The amount each user has locked up
    mapping(address => uint256) public lockupTimestamps; // The start time of the lockup for each user

    uint256 public requiredLockupAmount; // Required amount of STAT tokens to lock up
    uint256 public lockupDuration; // Duration of the lockup in seconds
    uint256 private totalLockedUpAmount; // Total amount of tokens locked up

    /// @notice Initializes the contract with the token address, required lockup amount, and lockup duration.
    /// @param _token The address of the STAT token contract.
    /// @param _lockupAmount The required amount of STAT tokens to lock up.
    /// @param _lockupDurationDays The duration of the lockup in days.
    constructor(address _token, uint256 _lockupAmount, uint256 _lockupDurationDays) 
        Ownable(msg.sender) {
        token = IERC20(_token);
        requiredLockupAmount = _lockupAmount;
        lockupDuration = _lockupDurationDays * 1 days; // Convert days to seconds
    }

    /// @notice Initiates a lockup for the caller's tokens.
    function statLockup(
    ) external nonReentrant whenNotPaused {
        require(lockedUpAmounts[msg.sender] == 0, "Already locked up");

        // Transfer tokens
        require(token.transferFrom(msg.sender, address(this), requiredLockupAmount), "Transfer failed");

        // Process the lockup
        lockedUpAmounts[msg.sender] = requiredLockupAmount;
        lockupTimestamps[msg.sender] = block.timestamp; // Lockup start time 
        totalLockedUpAmount += requiredLockupAmount; // Update total locked amount
    }

    /// @notice Allows users to withdraw their locked up tokens after the lockup period has ended.
    function withdrawLockup() external nonReentrant whenNotPaused {
        uint256 lockedAmount = lockedUpAmounts[msg.sender];
        require(lockedAmount > 0, "No locked up tokens to withdraw");
        require(block.timestamp >= lockupTimestamps[msg.sender] + lockupDuration, "Lockup period has not ended");

        require(token.transfer(msg.sender, lockedAmount), "Withdraw failed");
        lockedUpAmounts[msg.sender] = 0;
        lockupTimestamps[msg.sender] = 0;
        totalLockedUpAmount -= lockedAmount; // Update total locked amount
    }

    /// @notice Checks if an account has locked up tokens.
    /// @param account The address of the account to check.
    /// @return True if the account has locked up tokens, false otherwise.
    function hasLockedUp(address account) external view returns (bool) {
        return lockedUpAmounts[account] > 0;
    }

    /// @notice Retrieves the lockup duration for a specific account.
    /// @param account The address of the account.
    /// @return The lockup duration in seconds.
    function getLockupDuration(address account) external view returns (uint256) {
        require(lockedUpAmounts[account] > 0, "No locked up tokens");
        return block.timestamp - lockupTimestamps[account];
    }

    /// @notice Retrieves the remaining lockup time for a specific account.
    /// @param account The address of the account.
    /// @return The remaining lockup time in seconds.
    function getLockupTimeRemaining(address account) external view returns (uint256) {
        if (block.timestamp >= lockupTimestamps[account] + lockupDuration) {
            return 0;
        }
        return (lockupTimestamps[account] + lockupDuration) - block.timestamp;
    }

    // ---------- Administrator ---------- //

    /// @notice Updates the lockup duration.
    /// @param _durationDays The new lockup duration in days.
    /// @dev This function can only be called by the owner.
    function setLockupDuration(uint256 _durationDays) external onlyOwner {
        lockupDuration = _durationDays * 1 days; // Convert days to seconds
    }

    /// @notice Updates the required lockup amount.
    /// @param _amount The new required lockup amount.
    /// @dev This function can only be called by the owner.
    function setLockupAmount(uint256 _amount) external onlyOwner {
        requiredLockupAmount = _amount;
    }

    /// @notice Retrieves the total amount of locked up tokens.
    /// @return The total amount of locked up tokens.
    /// @dev This function can only be called by the owner.
    function getTotalLockedUpAmount() external view onlyOwner returns (uint256) {
        return totalLockedUpAmount;
    }

    /// @notice Updates the token contract address.
    /// @param newTokenContractAddress The new token contract address.
    /// @dev This function can only be called by the owner.
    function setTokenContractAddress(address newTokenContractAddress) external onlyOwner {
        require(newTokenContractAddress != address(0), "Invalid token address");
        token = IERC20(newTokenContractAddress);
    }

    /// @notice Pauses the contract.
    /// @dev This function can only be called by the owner.
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpauses the contract.
    /// @dev This function can only be called by the owner.
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Allows the owner to withdraw tokens in case of an emergency.
    /// @param _to The address to send the tokens to.
    /// @param _amount The amount of tokens to withdraw.
    /// @dev This function can only be called by the owner.
    function emergencyWithdraw(address _to, uint256 _amount) external onlyOwner {
        require(token.transfer(_to, _amount), "Withdraw failed");
    }
}