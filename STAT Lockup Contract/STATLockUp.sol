// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./TokenRegistry.sol";

using SafeERC20 for IERC20;

/// @title STATLockUp
/// @notice This contract allows users to lock up STAT tokens for a specified duration.
/// @dev Implements token lockup functionality with EIP-712 signature verification.
contract STATLockUp is ReentrancyGuard, Ownable, Pausable {
    using ECDSA for bytes32;

    address public immutable tokenRegistry; // TokenRegistry contract address

    /// @notice Authorized relayer address that can call withdrawLockupFor.
    address private relayer;

    mapping(address => uint256) public lockedUpAmounts; // The amount each user has locked up
    mapping(address => uint256) public lockupTimestamps; // The start time of the lockup for each user
    mapping(address => uint256) public userLockupDurations; // The lockup duration for each user

    uint256 public requiredLockupAmount; // Required amount of STAT tokens to lock up
    uint256 public lockupDuration; // Duration of the lockup in seconds (for new users)
    uint256 private totalLockedUpAmount; // Total amount of tokens locked up

    /// @notice Initializes the contract with the token registry address, required lockup amount, and lockup duration.
    /// @param _tokenRegistry The address of the TokenRegistry contract.
    /// @param _lockupAmount The required amount of STAT tokens to lock up.
    /// @param _lockupDurationDays The duration of the lockup in days.
    constructor(address _tokenRegistry, uint256 _lockupAmount, uint256 _lockupDurationDays) 
        Ownable(msg.sender) {
        require(_tokenRegistry != address(0), "Invalid TokenRegistry address");
        tokenRegistry = _tokenRegistry;
        requiredLockupAmount = _lockupAmount;
        lockupDuration = _lockupDurationDays * 1 days; // Convert days to seconds
    }

    /// @notice Restricts function to the authorized relayer only.
    modifier onlyRelayer() {
        require(msg.sender == relayer, "Caller is not relayer");
        _;
    }

    /// @notice Retrieves the token address from the TokenRegistry.
    function getTokenAddress() public view returns (IERC20) {
        return IERC20(TokenRegistry(tokenRegistry).getToken());
    }

    /// @notice Initiates a lockup for the caller's tokens.
    function statLockup() external nonReentrant whenNotPaused {
        require(lockedUpAmounts[msg.sender] == 0, "Already locked up");

        // Transfer tokens
        IERC20 token = getTokenAddress();
        token.safeTransferFrom(msg.sender, address(this), requiredLockupAmount);

        // Process the lockup
        lockedUpAmounts[msg.sender] = requiredLockupAmount;
        lockupTimestamps[msg.sender] = block.timestamp; // Lockup start time 
        userLockupDurations[msg.sender] = lockupDuration;
        totalLockedUpAmount += requiredLockupAmount; // Update total locked amount
    }

    /// @notice Allows users to withdraw their locked up tokens after the lockup period has ended.
    function withdrawLockup() external nonReentrant whenNotPaused {
        uint256 lockedAmount = lockedUpAmounts[msg.sender];
        require(lockedAmount > 0, "No locked up tokens to withdraw");
        require(lockupTimestamps[msg.sender] > 0, "Invalid lockup timestamp");
        require(userLockupDurations[msg.sender] > 0, "Invalid lockup duration");
        require(block.timestamp >= lockupTimestamps[msg.sender] + userLockupDurations[msg.sender], "Lockup period has not ended");

        lockedUpAmounts[msg.sender] = 0;
        lockupTimestamps[msg.sender] = 0;
        userLockupDurations[msg.sender] = 0;
        totalLockedUpAmount -= lockedAmount; // Update total locked amount

        IERC20 token = getTokenAddress();
        token.safeTransfer(msg.sender, lockedAmount);
    }

    /// @notice Locks up tokens on behalf of a user using a pre-approved permit.
    /// @dev This function is intended to be called by a relayer or backend on behalf of a user,
    ///      after the user has granted allowance via EIP-2612 permit.
    ///      The contract pulls tokens from the user's wallet using safeTransferFrom.
    /// @param user The address of the user whose tokens will be locked.
    function statLockupFor(address user) external nonReentrant whenNotPaused onlyRelayer {
        require(lockedUpAmounts[user] == 0, "Already locked up");

        IERC20 token = getTokenAddress();
        token.safeTransferFrom(user, address(this), requiredLockupAmount);

        lockedUpAmounts[user] = requiredLockupAmount;
        lockupTimestamps[user] = block.timestamp;
        userLockupDurations[user] = lockupDuration;
        totalLockedUpAmount += requiredLockupAmount;
    }

    /// @notice Relayer unlocks tokens on behalf of a user.
    /// @param user The address whose locked tokens will be withdrawn.
    function withdrawLockupFor(address user) external nonReentrant whenNotPaused onlyRelayer {
        uint256 lockedAmount = lockedUpAmounts[user];
        require(lockedAmount > 0, "No locked up tokens to withdraw");
        require(lockupTimestamps[user] > 0, "Invalid lockup timestamp");
        require(userLockupDurations[user] > 0, "Invalid lockup duration");
        require(block.timestamp >= lockupTimestamps[user] + userLockupDurations[user], "Lockup period has not ended");

        lockedUpAmounts[user] = 0;
        lockupTimestamps[user] = 0;
        userLockupDurations[user] = 0;
        totalLockedUpAmount -= lockedAmount;

        IERC20 token = getTokenAddress();
        token.safeTransfer(user, lockedAmount);
    }

    /// @notice Admin locks up tokens on behalf of a user.
    /// @param user The address of the user whose tokens will be locked.
    /// @dev Only callable by the owner.
    function adminStatLockupFor(address user) external onlyOwner nonReentrant whenNotPaused {
        require(user != address(0), "Invalid user");
        require(lockedUpAmounts[user] == 0, "Already locked up");

        IERC20 token = getTokenAddress();
        token.safeTransferFrom(msg.sender, address(this), requiredLockupAmount);

        lockedUpAmounts[user] = requiredLockupAmount;
        lockupTimestamps[user] = block.timestamp;
        userLockupDurations[user] = lockupDuration;
        totalLockedUpAmount += requiredLockupAmount;
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
        return userLockupDurations[account];
    }

    /// @notice Retrieves the remaining lockup time for a specific account.
    /// @param account The address of the account.
    /// @return The remaining lockup time in seconds.
    function getLockupTimeRemaining(address account) external view returns (uint256) {
        // Check if user has any locked tokens
        if (lockedUpAmounts[account] == 0 || lockupTimestamps[account] == 0) {
            return 0;
        }
        
        if (block.timestamp >= lockupTimestamps[account] + userLockupDurations[account]) {
            return 0;
        }
        return (lockupTimestamps[account] + userLockupDurations[account]) - block.timestamp;
    }

    // ---------- Administrator ---------- //

    /// @notice Sets the relayer address (onlyOwner).
    /// @param _relayer The address to be authorized as relayer.
    function setRelayer(address _relayer) external onlyOwner {
        require(_relayer != address(0), "Invalid relayer address");
        relayer = _relayer;
    }

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

    /// @notice Allows the owner to withdraw tokens in case of an emergency for redistribution.
    /// @param _to The address to send the tokens to.
    /// @param _amount The amount of tokens to withdraw.
    /// @dev This function can only be called by the owner.
    ///      WARNING: This may cause accounting inconsistencies. Use with extreme caution.
    function emergencyWithdraw(address _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "Invalid recipient address");
        require(_amount > 0, "Amount must be greater than 0");
        
        IERC20 token = getTokenAddress();
        uint256 contractBalance = token.balanceOf(address(this));
        require(contractBalance >= _amount, "Insufficient contract balance");
        require(totalLockedUpAmount >= _amount, "Amount exceeds total locked amount");
        
        token.safeTransfer(_to, _amount);

        totalLockedUpAmount -= _amount;
    }
}