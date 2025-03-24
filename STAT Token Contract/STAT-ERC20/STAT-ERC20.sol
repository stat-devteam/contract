// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title STAT Token (UUPS Upgradeable)
 * @dev ERC20 token with upgradeability, burnability, pausability, and transaction fee mechanism.
 */
contract STAT is 
    ERC20PermitUpgradeable, 
    ERC20BurnableUpgradeable, 
    ERC20PausableUpgradeable, 
    UUPSUpgradeable, 
    OwnableUpgradeable 
{
    /// @notice Mapping of admin addresses
    mapping(address => bool) private admins;
    
    /// @notice Transaction fee rate (in basis points, 10000 = 100%)
    uint256 public transferFeeRate;
    
    /// @notice Address to receive transaction fees
    address public feeRecipient;

    /// @notice Events for state changes
    event TransferFeeUpdated(uint256 feeRate);
    event FeeRecipientUpdated(address indexed recipient);
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);

    /// @notice Modifier to restrict function access to the admin or owner.
    modifier onlyAdmin() {
        require(admins[msg.sender] || msg.sender == owner(), "Not an admin or owner");
        _;
    }

    /**
     * @notice Initializes the STAT token contract.
     * @param name The name of the token.
     * @param symbol The symbol of the token.
     * @param initialSupply The initial supply of tokens (in smallest unit).
     * @param _feeRecipient The address that will receive transaction fees.
     */
    function initialize(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address _feeRecipient
    ) public initializer {
        __ERC20_init(name, symbol);
        __ERC20Permit_init(name);
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();

        _mint(msg.sender, initialSupply);
        feeRecipient = _feeRecipient;
        transferFeeRate = 0;
    }

    /**
     * @notice Authorizes contract upgrades. Only callable by the owner.
     * @param newImplementation The new implementation address.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyAdmin {}

    /**
     * @notice Updates the transaction fee rate.
     * @param feeRate The new fee rate (basis points, max 10000 = 100%).
     */
    function setTransferFee(uint256 feeRate) external onlyAdmin {
        transferFeeRate = feeRate;
        emit TransferFeeUpdated(feeRate);
    }

    /**
     * @notice Sets the recipient address for transaction fees.
     * @param recipient The address that will receive collected fees.
     */
    function setFeeRecipient(address recipient) external onlyAdmin {
        require(recipient != address(0), "Invalid address");
        feeRecipient = recipient;
        emit FeeRecipientUpdated(recipient);
    }

    /**
     * @notice Updates token state before transfers and applies the transaction fee.
     * @dev Overrides `_update()` from ERC20Upgradeable and ERC20PausableUpgradeable.
     */
    function _update(address from, address to, uint256 value) 
        internal 
        override(ERC20Upgradeable, ERC20PausableUpgradeable) 
    {
        if (transferFeeRate > 0 && from != address(0) && to != address(0)) { 
            // Calculate fee
            uint256 fee = (value * transferFeeRate) / 10000;
            uint256 netAmount = value - fee;

            // Send net amount to recipient
            super._update(from, to, netAmount);

            // Deduct fee and send to feeRecipient
            if (fee > 0) {
                super._update(from, feeRecipient, fee);
            }
        } else {
            // Normal transfer without fee
            super._update(from, to, value);
        }
    }

    /**
     * @notice Adds a new admin address.
     * @param adminAddress The address to be added as an admin.
     */
    function addAdmin(address adminAddress) external onlyAdmin {
        require(adminAddress != address(0), "Invalid address");
        require(!admins[adminAddress], "Already an admin");
        admins[adminAddress] = true;
        emit AdminAdded(adminAddress);
    }

    /**
     * @notice Removes an existing admin address.
     * @param adminAddress The address to be removed from admin role.
     */
    function removeAdmin(address adminAddress) external onlyAdmin {
        require(admins[adminAddress], "Not an admin");
        admins[adminAddress] = false;
        emit AdminRemoved(adminAddress);
    }

    /**
     * @notice Checks if an address is an admin.
     * @param adminAddress The address to check.
     * @return bool indicating whether the address is an admin.
     */
    function isAdmin(address adminAddress) external view returns (bool) {
        return admins[adminAddress];
    }
}