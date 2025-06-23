// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title RewardDistributor
 * @dev 미션별(missionId), 단계별(levelId) claim이 가능한 구조.
 *      운영자가 (user, amount, missionId, levelId, contract)로 서명,
 *      유저는 단계별로 개별 claim.
 *      각 서명(조합)별 중복 지급 방지.
 */
contract RewardDistributor is Pausable, ReentrancyGuard {
    using ECDSA for bytes32;

    IERC20 public rewardToken;
    address public owner;

    // 중복 사용(Replay) 방지 nonce 사용
    mapping(address => uint256) public lastClaimedNonce;
    
    // 추가된 상태 변수들
    uint256 public maxClaimAmount;
    mapping(address => bool) public blacklistedUsers;

    event RewardClaimed(
        address indexed user, 
        uint256 amount, 
        uint256 indexed nonce,
        uint256 timestamp
    );
    
    event RewardTokenUpdated(address indexed oldToken, address indexed newToken);
    event MaxClaimAmountUpdated(uint256 oldAmount, uint256 newAmount);
    event UserBlacklisted(address indexed user, bool isBlacklisted);
    event UserNonceReset(address indexed user);
    event OwnerUpdated(address indexed oldOwner, address indexed newOwner);

    constructor(address _rewardToken) {
        require(_rewardToken != address(0), "Invalid token address");
        require(msg.sender != address(0), "Invalid owner address");
        rewardToken = IERC20(_rewardToken);
        owner = msg.sender;
    }

    /**
     * @dev 동일 파라미터의 서명은 1회만 사용 가능.
     */
    function claim(
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) external whenNotPaused nonReentrant {
        require(!blacklistedUsers[msg.sender], "User is blacklisted");
        require(nonce == lastClaimedNonce[msg.sender] + 1, "Invalid nonce");
        require(maxClaimAmount == 0 || amount <= maxClaimAmount, "Amount exceeds max claim");
        require(rewardToken.balanceOf(address(this)) >= amount, "Insufficient balance");

        bytes32 hash = keccak256(
            abi.encodePacked(msg.sender, amount, nonce, address(this))
        );
        bytes32 ethSignedHash = MessageHashUtils.toEthSignedMessageHash(hash);
        require(ECDSA.recover(ethSignedHash, signature) == owner, "Invalid signature");

        lastClaimedNonce[msg.sender] = nonce;

        require(rewardToken.transfer(msg.sender, amount), "Transfer failed");
        emit RewardClaimed(msg.sender, amount, nonce, block.timestamp);
    }

    /**
     * @dev 운영자(서명자)가 남은 토큰 회수(운영상 필요시)
     */
    function withdraw(address to, uint256 amount) external {
        require(msg.sender == owner, "Only owner can withdraw");
        require(to != address(0), "Invalid address");
        require(rewardToken.transfer(to, amount), "Transfer failed");
    }

    function pause() external {
        require(msg.sender == owner, "Only owner can pause");
        _pause();
    }
    
    function unpause() external {
        require(msg.sender == owner, "Only owner can unpause");
        _unpause();
    }

    /**
     * @dev Owner 변경 (현재 owner만 가능)
     */
    function updateOwner(address newOwner) external {
        require(msg.sender == owner, "Only owner can update owner");
        require(newOwner != address(0), "Invalid new owner address");
        require(newOwner != owner, "New owner must be different");
        
        address oldOwner = owner;
        owner = newOwner;
        
        emit OwnerUpdated(oldOwner, newOwner);
    }

    /**
     * @dev 토큰 주소 업데이트 (owner만 가능)
     */
    function updateRewardToken(address newToken) external {
        require(msg.sender == owner, "Only owner can update token");
        require(newToken != address(0), "Invalid token address");
        
        address oldToken = address(rewardToken);
        rewardToken = IERC20(newToken);
        
        emit RewardTokenUpdated(oldToken, newToken);
    }

    /**
     * @dev 사용자 nonce 리셋 (긴급 상황용, owner만 가능)
     */
    function resetUserNonce(address user) external {
        require(msg.sender == owner, "Only owner can reset nonce");
        lastClaimedNonce[user] = 0;
        emit UserNonceReset(user);
    }

    /**
     * @dev 최대 클레임 금액 설정 (owner만 가능)
     */
    function setMaxClaimAmount(uint256 newMaxAmount) external {
        require(msg.sender == owner, "Only owner can set max claim amount");
        uint256 oldAmount = maxClaimAmount;
        maxClaimAmount = newMaxAmount;
        emit MaxClaimAmountUpdated(oldAmount, newMaxAmount);
    }

    /**
     * @dev 특정 사용자 블랙리스트 설정 (owner만 가능)
     */
    function blacklistUser(address user, bool isBlacklisted) external {
        require(msg.sender == owner, "Only owner can blacklist");
        blacklistedUsers[user] = isBlacklisted;
        emit UserBlacklisted(user, isBlacklisted);
    }

    /**
     * @dev 여러 사용자를 한 번에 블랙리스트 설정 (owner만 가능)
     */
    function blacklistUsers(address[] calldata users, bool isBlacklisted) external {
        require(msg.sender == owner, "Only owner can blacklist");
        require(users.length <= 100, "Too many users at once");
        for (uint256 i = 0; i < users.length; i++) {
            blacklistedUsers[users[i]] = isBlacklisted;
            emit UserBlacklisted(users[i], isBlacklisted);
        }
    }

    /**
     * @dev 사용자의 블랙리스트 상태 확인
     */
    function isUserBlacklisted(address user) external view returns (bool) {
        return blacklistedUsers[user];
    }

    /**
     * @dev 현재 토큰 잔액 조회
     */
    function getTokenBalance() external view returns (uint256) {
        return rewardToken.balanceOf(address(this));
    }

    /**
     * @dev 특정 사용자의 다음 nonce 조회
     */
    function getNextNonce(address user) external view returns (uint256) {
        return lastClaimedNonce[user] + 1;
    }
}