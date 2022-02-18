// File: openzeppelin-solidity/contracts/introspection/IERC165.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721.sol

pragma solidity ^0.5.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/GSN/Context.sol

pragma solidity ^0.5.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: openzeppelin-solidity/contracts/ownership/Secondary.sol

pragma solidity ^0.5.0;

/**
 * @dev A Secondary contract can only be used by its primary account (the one that created it).
 */
contract Secondary is Context {
    address private _primary;

    /**
     * @dev Emitted when the primary contract changes.
     */
    event PrimaryTransferred(
        address recipient
    );

    /**
     * @dev Sets the primary account to the one that is creating the Secondary contract.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _primary = msgSender;
        emit PrimaryTransferred(msgSender);
    }

    /**
     * @dev Reverts if called from any account other than the primary.
     */
    modifier onlyPrimary() {
        require(_msgSender() == _primary, "Secondary: caller is not the primary account");
        _;
    }

    /**
     * @return the address of the primary.
     */
    function primary() public view returns (address) {
        return _primary;
    }

    /**
     * @dev Transfers contract to a new primary.
     * @param recipient The address of new primary.
     */
    function transferPrimary(address recipient) public onlyPrimary {
        require(recipient != address(0), "Secondary: new primary is the zero address");
        _primary = recipient;
        emit PrimaryTransferred(recipient);
    }
}

// File: openzeppelin-solidity/contracts/utils/Address.sol

pragma solidity ^0.5.5;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following 
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: openzeppelin-solidity/contracts/payment/escrow/Escrow.sol

pragma solidity ^0.5.0;




 /**
  * @title Escrow
  * @dev Base escrow contract, holds funds designated for a payee until they
  * withdraw them.
  *
  * Intended usage: This contract (and derived escrow contracts) should be a
  * standalone contract, that only interacts with the contract that instantiated
  * it. That way, it is guaranteed that all Ether will be handled according to
  * the `Escrow` rules, and there is no need to check for payable functions or
  * transfers in the inheritance tree. The contract that uses the escrow as its
  * payment method should be its primary, and provide public methods redirecting
  * to the escrow's deposit and withdraw.
  */
contract Escrow is Secondary {
    using SafeMath for uint256;
    using Address for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    mapping(address => uint256) private _deposits;

    function depositsOf(address payee) public view returns (uint256) {
        return _deposits[payee];
    }

    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     * @param payee The destination address of the funds.
     */
    function deposit(address payee) public onlyPrimary payable {
        uint256 amount = msg.value;
        _deposits[payee] = _deposits[payee].add(amount);

        emit Deposited(payee, amount);
    }

    /**
     * @dev Withdraw accumulated balance for a payee, forwarding 2300 gas (a
     * Solidity `transfer`).
     *
     * NOTE: This function has been deprecated, use {withdrawWithGas} instead.
     * Calling contracts with fixed-gas limits is an anti-pattern and may break
     * contract interactions in network upgrades (hardforks).
     * https://diligence.consensys.net/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more.]
     *
     * @param payee The address whose funds will be withdrawn and transferred to.
     */
    function withdraw(address payable payee) public onlyPrimary {
        uint256 payment = _deposits[payee];

        _deposits[payee] = 0;

        payee.transfer(payment);

        emit Withdrawn(payee, payment);
    }

    /**
     * @dev Same as {withdraw}, but forwarding all gas to the recipient.
     *
     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.
     * Make sure you trust the recipient, or are either following the
     * checks-effects-interactions pattern or using {ReentrancyGuard}.
     *
     * _Available since v2.4.0._
     */
    function withdrawWithGas(address payable payee) public onlyPrimary {
        uint256 payment = _deposits[payee];

        _deposits[payee] = 0;

        payee.sendValue(payment);

        emit Withdrawn(payee, payment);
    }
}

// File: openzeppelin-solidity/contracts/payment/PullPayment.sol

pragma solidity ^0.5.0;


/**
 * @dev Simple implementation of a
 * https://consensys.github.io/smart-contract-best-practices/recommendations/#favor-pull-over-push-for-external-calls[pull-payment]
 * strategy, where the paying contract doesn't interact directly with the
 * receiver account, which must withdraw its payments itself.
 *
 * Pull-payments are often considered the best practice when it comes to sending
 * Ether, security-wise. It prevents recipients from blocking execution, and
 * eliminates reentrancy concerns.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 *
 * To use, derive from the `PullPayment` contract, and use {_asyncTransfer}
 * instead of Solidity's `transfer` function. Payees can query their due
 * payments with {payments}, and retrieve them with {withdrawPayments}.
 */
contract PullPayment {
    Escrow private _escrow;

    constructor () internal {
        _escrow = new Escrow();
    }

    /**
     * @dev Withdraw accumulated payments.
     *
     * Note that _any_ account can call this function, not just the `payee`.
     * This means that contracts unaware of the `PullPayment` protocol can still
     * receive funds this way, by having a separate account call
     * {withdrawPayments}.
     *
     * NOTE: This function has been deprecated, use {withdrawPaymentsWithGas}
     * instead. Calling contracts with fixed gas limits is an anti-pattern and
     * may break contract interactions in network upgrades (hardforks).
     * https://diligence.consensys.net/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more.]
     *
     * @param payee Whose payments will be withdrawn.
     */
    function withdrawPayments(address payable payee) public {
        _escrow.withdraw(payee);
    }

    /**
     * @dev Same as {withdrawPayments}, but forwarding all gas to the recipient.
     *
     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.
     * Make sure you trust the recipient, or are either following the
     * checks-effects-interactions pattern or using {ReentrancyGuard}.
     *
     * _Available since v2.4.0._
     */
    function withdrawPaymentsWithGas(address payable payee) external {
        _escrow.withdrawWithGas(payee);
    }

    /**
     * @dev Returns the payments owed to an address.
     * @param dest The creditor's address.
     */
    function payments(address dest) public view returns (uint256) {
        return _escrow.depositsOf(dest);
    }

    /**
     * @dev Called by the payer to store the sent amount as credit to be pulled.
     * Funds sent in this way are stored in an intermediate {Escrow} contract, so
     * there is no danger of them being spent before withdrawal.
     *
     * @param dest The destination address of the funds.
     * @param amount The amount to transfer.
     */
    function _asyncTransfer(address dest, uint256 amount) internal {
        _escrow.deposit.value(amount)(dest);
    }
}

// File: contracts/ITxProxy.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.5.6;

interface ITxProxy {
    function sendMoney(address payable _to) external payable;
}

// File: contracts/TxProxy.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.5.6;


contract TxProxy is ITxProxy {
    function sendMoney(address payable _to) external payable {
        _to.transfer(msg.value);
    }
}

// File: contracts/MaybeSendMoney.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.5.6;


contract MaybeSendMoney {
    TxProxy proxy;

    constructor() internal {
        proxy = new TxProxy();
    }

    function maybeSendMoney(address payable _to, uint256 _value) internal returns (bool)
    {
        (bool success, bytes memory _) = address(proxy).call.value(_value)( abi.encodeWithSignature("sendMoney(address)", _to));
        return success;
    }
}

// File: contracts/SendMoneyOrEscrow.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.5.6;




contract SendMoneyOrEscrow is Ownable, MaybeSendMoney, PullPayment {
    function sendMoneyOrEscrow(address payable _to, uint256 _value) internal {
        bool successfulTransfer = maybeSendMoney(_to, _value);
        if (!successfulTransfer) {
            _asyncTransfer(_to, _value);
        }
    }
}

// File: contracts/IERC721Creator.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.5.6;


contract IERC721Creator is IERC721 {
    function tokenCreator(uint256 _tokenId) external view returns (address payable);
}

// File: contracts/XenoMarketplace.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.5.6;

contract Marketplace is Ownable, SendMoneyOrEscrow {
    using SafeMath for uint256;

    struct ActiveBid {
        bytes32 a_id;
        bytes32 b_id;
        address payable bidder;
        uint256 marketplaceFee;
        uint256 price;
        uint256 startingAt;
        uint256 expiredAt;
    }

    struct Auction {
        uint256 saleType;
        bytes32 a_id;
        address payable seller;
        address creator;
        address partner;
        uint256 price;
        uint256 endingPrice;
        uint256 startingAt;        
        uint256 expiredAt;
        AuctionStatus status;
    }

    struct RoyaltySettings {
        IERC721Creator iErc721CreatorContract;
        uint256 percentage;
    }

    uint256 private marketplaceFeePercentage;
    uint256 private partnerFeePercentage;
    uint256 private creatorFeePercentage;
    
    uint256 private constant AUCTION    = 1;
    uint256 private constant BUYNOW     = 2;


    uint256 constant maximumPercentage = 1000;
    uint256 public constant maximumMarketValue = 2**255;
    uint256 public minimumBidIncreasePercentage = 10; // 1% -- 100 = 10%

    // MarketplaceSettings public marketplaceFeeSet = MarketplaceSettings(0, 25);

    enum AuctionStatus {
        Live,
        Closed,
        Canceled
    }

    mapping(address => uint8) private primarySaleFees;
    mapping(address => mapping(uint256 => Auction)) private tokenPrices;
    mapping(address => mapping(uint256 => bool)) private soldTokens;
    mapping(address => mapping(uint256 => ActiveBid)) private tokenCurrentBids;
    mapping(address => RoyaltySettings) private contractRoyaltySettings;
    mapping(address => uint256) private contractPrimarySaleFee;
    mapping(address => mapping(uint256 => uint256)) private tokenRoyaltyPercentage;
    mapping(address => uint256) private creatorRoyaltyPercentage;
    mapping(address => uint256) private contractRoyaltyPercentage;


    event Sold(
        uint256 _type,
        bytes32 _a_id,
        address indexed _tokenAddress,
        address indexed _buyer,
        address indexed _seller,
        uint256 _amount,
        uint256 _tokenId
        // uint256 _startingAt,
        // uint256 _expiredAt
    );

    event CreateOrder(
        uint256 _type,
        bytes32 _a_id,
        address indexed _seller,
        address indexed _tokenAddress,
        uint256 _startingPrice,
        uint256 _tokenId,
        uint256 _startingAt,
        uint256 _expiredAt
    );

    event Bid(
        bytes32 _a_id,
        bytes32 _b_id,
        address indexed _seller,
        uint256 _startPrice,
        address indexed _tokenAddress,
        address indexed _bidder,
        uint256 _amount,
        uint256 _tokenId
    );

    event AcceptBid(
        bytes32 _a_id,
        bytes32 _b_id,
        address indexed _seller,
        uint256 _startPrice,
        address indexed _tokenAddress,
        address indexed _bidder,
        uint256 _amount,
        uint256 _tokenId
        // uint256 _expiredAt
    );

    event CancelBid(
        bytes32 _a_id,
        bytes32 _b_id,
        address indexed _seller,
        uint256 _startPrice,
        address indexed _tokenAddress,
        address indexed _bidder,
        uint256 _amount,
        uint256 _tokenId
        // uint256 _expiredAt
    );


    // event CancelOrder(
    //     bytes32 _a_id,
    //     address indexed _tokenAddress,
    //     uint256 _tokenId
    // );

    event CancelOrder(
        uint256 _type,
        bytes32 _a_id,
        address indexed _seller,
        address indexed _tokenAddress,
        uint256 _amount,
        uint256 _tokenId
        // uint256 _expiredAt
    );    

    event ForceClose(
        uint256 _type,
        bytes32 _a_id,
        address indexed _seller,
        address indexed _tokenAddress,
        uint256 _amount,
        uint256 _tokenId
        // uint256 _expiredAt
    );    


    event RoyaltySettingsSet(
        address indexed _erc721CreatorContract,
        uint256 _percentage
    );

    event PrimarySalePercentageSet(
        address indexed _tokenAddress,
        uint256 _percentage
    );

// --- Owner ---
    address private maintainer;

    constructor(address _maintainer) public {
        maintainer = _maintainer;
        partnerFeePercentage = 300; // 30% partner fee on all txs.
        marketplaceFeePercentage = 100; // 10% marketplace fee on all txs.
        creatorFeePercentage = 600; // 60% creator calc price.
    }

    function getPartnerFeePercentage() public view returns (uint256)
    {
        return partnerFeePercentage;
    }

    function setPartnerFeePercentage(uint256 _percentage) public onlyOwner {
        require( _percentage <= 100, "setPartnerFeePercentage::_percentage must be <= 100");
        partnerFeePercentage = _percentage * 10;
    }

    function getMarketplaceFeePercentage() public view returns (uint256)
    {
        return marketplaceFeePercentage;
    }

    function setMarketplaceFeePercentage(uint256 _percentage) public onlyOwner {
        require( _percentage <= 100, "setMarketplaceFeePercentage::_percentage must be <= 100");
        marketplaceFeePercentage = _percentage * 10;
    }
    
    function getCreatorFeePercentage() public view returns (uint256)
    {
        return creatorFeePercentage;
    }

    function setCreatorFeePercentage(uint256 _percentage) public onlyOwner {
        require( _percentage <= 100, "setCreatorFeePercentage::_percentage must be <= 100");
        creatorFeePercentage = _percentage * 10;
    }

    function getERC721ContractPrimarySaleFeePercentage(address _contractAddress) public view returns (uint256)
    {
        return primarySaleFees[_contractAddress];
    }

    function setERC721ContractPrimarySaleFeePercentage( address _contractAddress, uint8 _percentage ) public onlyOwner {
        require( _percentage <= 1000, "setERC721ContractPrimarySaleFeePercentage::_percentage must be <= 1000");
        primarySaleFees[_contractAddress] = _percentage;
    }

    function setMinimumBidIncreasePercentage(uint8 _percentage) public onlyOwner
    {
        minimumBidIncreasePercentage = _percentage;
    }    

    function ownerMustHaveMarketplaceApproved( address _tokenAddress, uint256 _tokenId ) internal view {
        IERC721 erc721 = IERC721(_tokenAddress);
        address owner = erc721.ownerOf(_tokenId);
        require( erc721.isApprovedForAll(owner, address(this)), "owner must have approved contract");
    }

    function senderMustBeTokenOwner(address _tokenAddress, uint256 _tokenId) internal view {
        IERC721 erc721 = IERC721(_tokenAddress);
        require( erc721.ownerOf(_tokenId) == msg.sender, "sender must be the token owner");
    }

    function createBuyNow( address _tokenAddress, uint256 _tokenId, uint256 _price, uint256 _startingAt, uint256 _expiredAt, address _creator, address _partner) external {
        if(_startingAt <= block.timestamp)
        {
            _createOrder( BUYNOW, _tokenAddress, _tokenId, _price, _price, block.timestamp, _expiredAt, _creator, _partner);
        }
        else 
        {
            _createOrder( BUYNOW, _tokenAddress, _tokenId, _price, _price, _startingAt, _expiredAt, _creator, _partner);
        }
        
    }

    function createAuction( address _tokenAddress, uint256 _tokenId, uint256 _price, uint256 _endingPrice, uint256 _startingAt, uint256 _expiredAt, address _creator, address _partner) external {
        require( !_tokenHasBid(_tokenAddress, _tokenId ), "createOrder::Order already exists");
        _createOrder( AUCTION, _tokenAddress, _tokenId, _price, _endingPrice, _startingAt, _expiredAt, _creator, _partner);
    }

    function _createOrder( uint256 _type, address _tokenAddress, uint256 _tokenId, uint256 _price, uint256 _endingPrice, uint256 _startingAt, uint256 _expiredAt, address _creator, address _partner) internal {
        ownerMustHaveMarketplaceApproved(_tokenAddress, _tokenId);
        senderMustBeTokenOwner(_tokenAddress, _tokenId);
        require(_price > 0, "createOrder::Price should be bigger than 0");
        require( _price <= maximumMarketValue, "createOrder::Cannot set sale price larger than max value" );
        require( _startingAt < _expiredAt, "createOrder::Cannot _startingAt larger than _expiredAt" );

        bytes32 _orderId = keccak256(
            abi.encodePacked(
                block.timestamp,
                msg.sender,
                _tokenAddress,
                _tokenId,
                _price
            )
        );
        
        tokenPrices[_tokenAddress][_tokenId] = Auction(_type, _orderId, msg.sender, _creator, _partner, _price, _endingPrice, _startingAt, _expiredAt, AuctionStatus.Live);
        emit CreateOrder(_type, _orderId, msg.sender, _tokenAddress, _price, _tokenId, _startingAt, _expiredAt);
    }

    function cancelOrder(address _tokenAddress, uint256 _tokenId) external payable {
        require(tokenPrices[_tokenAddress][_tokenId].seller == msg.sender, "cancelOrder::seller only can cancel order.");
        Auction memory sp = tokenPrices[_tokenAddress][_tokenId];
        _closeOrder(_tokenAddress, _tokenId);
        emit CancelOrder(sp.saleType, sp.a_id, sp.seller, _tokenAddress, sp.price, _tokenId);
    }

    function forceClose(address _tokenAddress, uint256 _tokenId) external payable onlyOwner{
        Auction memory sp = tokenPrices[_tokenAddress][_tokenId];
        _closeOrder(_tokenAddress, _tokenId);
        // emit ForceClose(sp.a_id, _tokenAddress, _tokenId);   
        emit ForceClose(sp.saleType, sp.a_id, sp.seller, _tokenAddress, sp.price, _tokenId);
    }

    function _closeOrder(address _tokenAddress, uint256 _tokenId) private {
        if(_tokenHasBid(_tokenAddress, _tokenId )) {
            _refundBid(_tokenAddress, _tokenId);
        }
        _resetTokenPrice(_tokenAddress, _tokenId, AuctionStatus.Closed);
    }

    function buy(address _tokenAddress, uint256 _tokenId) public payable {
        ownerMustHaveMarketplaceApproved(_tokenAddress, _tokenId);
        require(_priceSetterStillOwnsTheToken(_tokenAddress, _tokenId),"buy::Current token owner must be the person to have the latest price.");

        Auction memory sp = tokenPrices[_tokenAddress][_tokenId];
        require(sp.price > 0, "buy::Tokens priced at 0 are not for sale.");
        require(sp.price == msg.value,"buy::Must purchase the token for the correct price");
        require(sp.startingAt <= block.timestamp, "buy::startingAt is larger than block.timestamp.");
        require(sp.saleType == BUYNOW, "buy::Auction mode does not support this func.");
        require(sp.creator != address(0), "payout::invalidate creator address");
        require(sp.partner != address(0), "payout::invalidate partner address");

        IERC721 erc721 = IERC721(_tokenAddress);
        address tokenOwner = erc721.ownerOf(_tokenId);
        erc721.safeTransferFrom(tokenOwner, msg.sender, _tokenId);
        _resetTokenPrice(_tokenAddress, _tokenId, AuctionStatus.Closed);
        _setTokenAsSold(_tokenAddress, _tokenId);

        _payout(sp.price, _makePayable(tokenOwner), _tokenAddress, _tokenId, sp.creator, sp.partner);
        emit Sold(sp.saleType, sp.a_id, _tokenAddress, msg.sender, tokenOwner, sp.price, _tokenId);
    }

    function tokenPrice(address _tokenAddress, uint256 _tokenId) external view returns (uint256)
    {
        ownerMustHaveMarketplaceApproved(_tokenAddress, _tokenId);
        if (_priceSetterStillOwnsTheToken(_tokenAddress, _tokenId)) {
            return tokenPrices[_tokenAddress][_tokenId].price;
        }
        return 0;
    }

    function bid( address _tokenAddress, uint256 _tokenId, uint256 _newBidprice) external payable {
        Auction memory sp = tokenPrices[_tokenAddress][_tokenId];
        require(block.timestamp >= sp.startingAt, "bid:: not started.");
        require(block.timestamp < sp.expiredAt, "bid:: already expired.");
        require(sp.saleType == AUCTION, "buy::Buy Now mode does not support this func.");
        require(_newBidprice > 0, "bid::Cannot bid 0 Wei.");
        require(_newBidprice == msg.value,"buy::Must purchase the token for the correct price");
        require(_newBidprice <= maximumMarketValue, "bid::Cannot bid higher than max value");
        if (sp.endingPrice > 0) {
            require(_newBidprice <= sp.endingPrice, "bid::Overflow ending price");
        }
        
        uint256 currentBidprice = tokenCurrentBids[_tokenAddress][_tokenId].price;
        
        if (_newBidprice == sp.endingPrice) {
            // 즉시 구매 (AcceptBid)
            _refundBid(_tokenAddress, _tokenId);

            IERC721 erc721 = IERC721(_tokenAddress);
            address tokenOwner = erc721.ownerOf(_tokenId);
            erc721.safeTransferFrom(tokenOwner, msg.sender, _tokenId);

            _resetTokenPrice(_tokenAddress, _tokenId, AuctionStatus.Closed);
            _setTokenAsSold(_tokenAddress, _tokenId);
            _payout(sp.endingPrice, _makePayable(tokenOwner), _tokenAddress, _tokenId, sp.creator, sp.partner);

            emit AcceptBid(sp.a_id, 0, sp.seller, sp.price, _tokenAddress, msg.sender, _newBidprice, _tokenId);
            
        } else {
            // 비딩 (Bid)
            require( _newBidprice > currentBidprice, "bid::Must place higher bid than existing bid.");
             // Must bid higher than current bid.
            require( _newBidprice > currentBidprice && _newBidprice >= currentBidprice.add( currentBidprice.mul(minimumBidIncreasePercentage).div(1000)), "bid::must bid higher than previous bid + minimum percentage increase.");
            
            bytes32 _bidId = keccak256(
                abi.encodePacked(
                    block.timestamp,
                    msg.sender,
                    sp.a_id,
                    _newBidprice,
                    sp.expiredAt
                )
            );
    
            IERC721 erc721 = IERC721(_tokenAddress);
            address tokenOwner = erc721.ownerOf(_tokenId);
            require(tokenOwner != msg.sender, "bid::Bidder cannot be owner.");
            _refundBid(_tokenAddress, _tokenId);
            _setBid(sp.a_id, _bidId, _newBidprice, msg.sender, _tokenAddress, _tokenId, sp.startingAt, sp.expiredAt);
    
            emit Bid(sp.a_id, _bidId, sp.seller, sp.price, _tokenAddress, msg.sender, _newBidprice, _tokenId);
        }
        
    }

    function getBlockTime() public view returns (uint256) {
        return block.timestamp;
    } 

    function acceptBid(address _tokenAddress, uint256 _tokenId) public {
        Auction memory sp = tokenPrices[_tokenAddress][_tokenId];
        require(sp.saleType == AUCTION, "buy::Buy Now mode  does not support this func.");
        
        ownerMustHaveMarketplaceApproved(_tokenAddress, _tokenId);
        senderMustBeTokenOwner(_tokenAddress, _tokenId);
        
        require( _tokenHasBid(_tokenAddress, _tokenId), "acceptBid::Cannot accept a bid when there is none.");        
        require(sp.expiredAt < block.timestamp);
        require(sp.creator != address(0), "payout::invalidate creator address");
        require(sp.partner != address(0), "payout::invalidate partner address");

        ActiveBid memory currentBid = tokenCurrentBids[_tokenAddress][_tokenId];
        
        IERC721 erc721 = IERC721(_tokenAddress);
        erc721.safeTransferFrom(msg.sender, currentBid.bidder, _tokenId);
        
        _payout(currentBid.price, _makePayable(msg.sender), _tokenAddress, _tokenId, sp.creator, sp.partner);
        
        _resetTokenPrice(_tokenAddress, _tokenId, AuctionStatus.Closed);
        _resetBid(_tokenAddress, _tokenId);
        _setTokenAsSold(_tokenAddress, _tokenId);
        emit AcceptBid(currentBid.a_id, currentBid.b_id, sp.seller, sp.price, _tokenAddress, currentBid.bidder, currentBid.price, _tokenId);
    }

    function cancelBid(address _tokenAddress, uint256 _tokenId) external {
        Auction memory sp = tokenPrices[_tokenAddress][_tokenId];
        ActiveBid memory currentBid = tokenCurrentBids[_tokenAddress][_tokenId];
        require(sp.saleType == AUCTION, "buy::Buy Now mode does not support this func.");
        require(_checkBidder(msg.sender, _tokenAddress, _tokenId),"cancelBid::Cannot cancel a bid if sender hasn't made one.");
        _refundBid(_tokenAddress, _tokenId);
        emit CancelBid(currentBid.a_id, currentBid.b_id, sp.seller, sp.price, _tokenAddress,msg.sender,tokenCurrentBids[_tokenAddress][_tokenId].price,_tokenId);
    }

    function getCurrentBid(address _tokenAddress, uint256 _tokenId) public view returns (uint256, address)
    {
        return (tokenCurrentBids[_tokenAddress][_tokenId].price, tokenCurrentBids[_tokenAddress][_tokenId].bidder);
    }

    function getOrderInfo(address _tokenAddress, uint256 _tokenId) public view returns (uint256, address, uint256, uint256, uint256, address, address)
    {
        Auction memory sp = tokenPrices[_tokenAddress][_tokenId];
        return (sp.saleType, sp.seller, sp.price, sp.endingPrice, sp.expiredAt, sp.creator, sp.partner);
    }

    function hasTokenBeenSold(address _tokenAddress, uint256 _tokenId) external view returns (bool)
    {
        return soldTokens[_tokenAddress][_tokenId];
    }

    function _priceSetterStillOwnsTheToken( address _tokenAddress, uint256 _tokenId ) internal view returns (bool) {
        IERC721 erc721 = IERC721(_tokenAddress);
        return erc721.ownerOf(_tokenId) == tokenPrices[_tokenAddress][_tokenId].seller;
    }

    function _payout( uint256 _amount, address payable _seller, address _tokenAddress, uint256 _tokenId, address _creatorAddress, address _partnerAddress) private {
        uint256[4] memory payments;
        
        // uint256 marketplaceFee
        payments[0] = calcPercentagePayment(_amount, getMarketplaceFeePercentage());
        
        // unit256 creatorFee
        payments[1] = calcPercentagePayment(_amount, getCreatorFeePercentage());

        // unit256 partnerFee
        payments[2] = calcPercentagePayment(_amount, getPartnerFeePercentage());

        // marketplacePayment
        if (payments[0] > 0) {
            sendMoneyOrEscrow(_makePayable(maintainer), payments[0]);
        }
        // creatorPayment
        if (payments[1] > 0) {
            require(_creatorAddress != address(0), "payout::invalidate creator address");
            sendMoneyOrEscrow(_makePayable(_creatorAddress), payments[1]);
        }
        // partnerPayment
        if (payments[2] > 0) {
            require(_partnerAddress != address(0), "payout::invalidate partner address");
            sendMoneyOrEscrow(_makePayable(_partnerAddress), payments[2]);
        }
    }

    // New Added
    function calcPercentagePayment(uint256 _amount, uint256 _percentage) internal pure returns (uint256)
    {
        return _amount.mul(_percentage).div(1000);
    }

    function _setTokenAsSold(address _tokenAddress, uint256 _tokenId) internal
    {
        if (soldTokens[_tokenAddress][_tokenId]) {
            return;
        }
        soldTokens[_tokenAddress][_tokenId] = true;
    }

    function _resetTokenPrice(address _tokenAddress, uint256 _tokenId, AuctionStatus _status) internal
    {
        tokenPrices[_tokenAddress][_tokenId] = Auction(0, 0, address(0), address(0), address(0), 0, 0, 0, 0, _status);
    }

    function _checkBidder( address _bidder, address _tokenAddress, uint256 _tokenId ) internal view returns (bool) {
        return tokenCurrentBids[_tokenAddress][_tokenId].bidder == _bidder;
    }

    function _tokenHasBid(address _tokenAddress, uint256 _tokenId) internal view returns (bool)
    {
        return tokenCurrentBids[_tokenAddress][_tokenId].bidder != address(0);
    }

    function _refundBid(address _tokenAddress, uint256 _tokenId) internal {
        ActiveBid memory currentBid = tokenCurrentBids[_tokenAddress][_tokenId];
        if (currentBid.bidder == address(0)) {
            return;
        }
        
        _resetBid(_tokenAddress, _tokenId);
        sendMoneyOrEscrow(currentBid.bidder, currentBid.price);
    }

    function _resetBid(address _tokenAddress, uint256 _tokenId) internal { 
        tokenCurrentBids[_tokenAddress][_tokenId] = ActiveBid(0, 0, address(0),0,0,0,0);
    }

    function _setBid( bytes32 _aucId,  bytes32 _bidId, uint256 _price, address payable _bidder, address _tokenAddress, uint256 _tokenId, uint256 _startingAt, uint256 _expiredAt) internal {
        require(_bidder != address(0), "Bidder cannot be 0 address.");
        tokenCurrentBids[_tokenAddress][_tokenId] = ActiveBid(_aucId, _bidId, _bidder, getMarketplaceFeePercentage(), _price, _startingAt, _expiredAt);
    }

    function _makePayable(address _address) internal pure returns (address payable) {
        return address(uint160(_address));
    }
}