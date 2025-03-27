// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title STAT Token
 * @dev Standard ERC20 token with burnable and pausable features, includes permit functionality (EIP-2612).
 */
contract STAT is ERC20Permit, ERC20Burnable, ERC20Pausable, Ownable {
    /// @notice Mapping to track admin addresses
    mapping(address => bool) private admins;

    /// @notice Emitted when a new admin is added
    event AdminAdded(address indexed admin);
    /// @notice Emitted when an admin is removed
    event AdminRemoved(address indexed admin);

    /// @notice Modifier to restrict function access to admins or the owner
    modifier onlyAdmin() {
        require(admins[msg.sender] || msg.sender == owner(), "Not an admin or owner");
        _;
    }

    /**
     * @notice Initializes the STAT token with name, symbol, and initial supply.
     * @param name The name of the token.
     * @param symbol The symbol of the token.
     * @param initialSupply The initial total supply (in smallest units).
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) ERC20Permit(name) Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }

    /**
     * @notice Pauses all token transfers.
     * @dev Can only be called by an admin or the owner.
     */
    function pause() external onlyAdmin {
        _pause();
    }

    /**
     * @notice Unpauses all token transfers.
     * @dev Can only be called by an admin or the owner.
     */
    function unpause() external onlyAdmin {
        _unpause();
    }

    /**
     * @dev Hook that is called before any transfer of tokens.
     * Includes logic for pausable functionality.
     */
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }

    /**
     * @notice Adds a new admin address.
     * @param adminAddress The address to be granted admin rights.
     */
    function addAdmin(address adminAddress) external onlyAdmin {
        require(adminAddress != address(0), "Invalid address");
        require(!admins[adminAddress], "Already an admin");
        admins[adminAddress] = true;
        emit AdminAdded(adminAddress);
    }

    /**
     * @notice Removes an admin address.
     * @param adminAddress The address to be removed from admin role.
     */
    function removeAdmin(address adminAddress) external onlyAdmin {
        require(admins[adminAddress], "Not an admin");
        admins[adminAddress] = false;
        emit AdminRemoved(adminAddress);
    }

    /**
     * @notice Checks whether an address has admin privileges.
     * @param adminAddress The address to check.
     * @return True if the address is an admin, false otherwise.
     */
    function isAdmin(address adminAddress) external view returns (bool) {
        return admins[adminAddress];
    }
}
