// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract STATLockUp is EIP712, ReentrancyGuard, Ownable, Pausable {
    using ECDSA for bytes32;

    IERC20 public token;

    mapping(address => uint256) public lockedUpAmounts; // 유저가 얼마를 락업 했는지
    mapping(address => uint256) public lockupTimestamps; // 락업 시작 시간

    uint256 public requiredLockupAmount; // 필요 락업 STAT 수량 = n STAT * 10**18;
    uint256 public lockupDuration; // 락업 기간 (초 단위)
    uint256 private totalLockedUpAmount; // 전체 예치된 금액

    constructor(address _token, uint256 _lockupAmount, uint256 _lockupDurationDays) EIP712("STATLockUp", "1") Ownable(msg.sender) {
        token = IERC20(_token);
        requiredLockupAmount = _lockupAmount;
        lockupDuration = _lockupDurationDays * 1 days; // 일 단위에서 초 단위로 변환
    }

    // ---------- 유저 액션 함수 ----------- //

    function statLockup(
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant whenNotPaused {
        require(block.timestamp <= deadline, "Permit: expired deadline");
        require(lockedUpAmounts[msg.sender] == 0, "Already locked up");

        // 메시지 해시 재구성
        bytes32 structHash = keccak256(abi.encode(
            keccak256("Permit(address from,uint256 value,uint256 deadline)"),
            msg.sender,
            requiredLockupAmount,
            deadline
        ));
        bytes32 digest = _hashTypedDataV4(structHash);

        // 서명 검증
        address signer = ECDSA.recover(digest, v, r, s);

        require(signer == msg.sender, "Invalid signature");

        // require(signer == msg.sender, string(
        //     abi.encodePacked(
        //         "Invalid signature: expected ", 
        //         toAsciiString(msg.sender), 
        //         " but got ", 
        //         toAsciiString(signer), 
        //         ". StructHash: ", 
        //         bytes32ToString(structHash), 
        //         ", MessageHash: ", 
        //         bytes32ToString(digest), 
        //         ", v: ", 
        //         uintToString(v), 
        //         ", r: ", 
        //         bytes32ToString(r), 
        //         ", s: ", 
        //         bytes32ToString(s)
        //     )
        // ));

        // 토큰 전송
        require(token.transferFrom(msg.sender, address(this), requiredLockupAmount), "Transfer failed");

        // Lockup 처리
        lockedUpAmounts[msg.sender] = requiredLockupAmount;
        lockupTimestamps[msg.sender] = block.timestamp; // 락업 시간 
        totalLockedUpAmount += requiredLockupAmount; // 전체 예치된 금액 업데이트
    }

    // 유저가 예치한 금액을 다시 뺄 수 있는 함수
    function withdrawLockup() external nonReentrant whenNotPaused {
        uint256 lockedAmount = lockedUpAmounts[msg.sender];
        require(lockedAmount > 0, "No locked up tokens to withdraw");
        require(block.timestamp >= lockupTimestamps[msg.sender] + lockupDuration, "Lockup period has not ended");

        require(token.transfer(msg.sender, lockedAmount), "Withdraw failed");
        lockedUpAmounts[msg.sender] = 0;
        lockupTimestamps[msg.sender] = 0;
        totalLockedUpAmount -= lockedAmount; // 전체 예치된 금액 업데이트
    }


    // ---------- 유저 조회 함수 ---------- //

    // 지갑 주소를 입력받아 STAT을 예치했는지 여부를 체크
    function hasLockedUp(address account) external view returns (bool) {
        return lockedUpAmounts[account] > 0;
    }

    // 지갑 주소를 입력받아 락업한 지 얼마나 지났는지 반환하는 함수
    function getLockupDuration(address account) external view returns (uint256) {
        require(lockedUpAmounts[account] > 0, "No locked up tokens");
        return block.timestamp - lockupTimestamps[account];
    }

    // 지갑 주소를 입력받아 잔여 락업 기간을 반환하는 함수
    function getLockupTimeRemaining(address account) external view returns (uint256) {
        if (block.timestamp >= lockupTimestamps[account] + lockupDuration) {
            return 0;
        }
        return (lockupTimestamps[account] + lockupDuration) - block.timestamp;
    }


    // ---------- 관리자 관리 함수 ---------- //

    // lockupDuration을 변경할 수 있는 함수 (onlyOwner)
    function setLockupDuration(uint256 _durationDays) external onlyOwner {
        lockupDuration = _durationDays * 1 days; // 일 단위에서 초 단위로 변환
    }

    // requiredLockupAmount 변경할 수 있는 함수 (onlyOwner)
    function setLockupAmount(uint256 _amount) external onlyOwner {
        requiredLockupAmount = _amount;
    }

    // 현재 예치된 금액의 총액을 반환하는 함수 (onlyOwner)
    function getTotalLockedUpAmount() external view onlyOwner returns (uint256) {
        return totalLockedUpAmount;
    }
    
    // STAT 토큰의 컨트랙트 주소 변경이 필요 할 시 사용하는 함수 (onlyOwner)
    function setTokenContractAddress(address newTokenContractAddress) external onlyOwner {
        require(newTokenContractAddress != address(0), "Invalid token address");
        token = IERC20(newTokenContractAddress);
    }

    // Only owner can pause the contract
    function pause() external onlyOwner {
        _pause();
    }

    // Only owner can unpause the contract
    function unpause() external onlyOwner {
        _unpause();
    }

    // Emergency Only: Only owner can withdraw locked up token when emergency situation happened
    function emergencyWithdraw(address _to, uint256 _amount) external onlyOwner {
        require(token.transfer(_to, _amount), "Withdraw failed");
    }


    // // ---------- 헬퍼 함수 ---------- //

    // // 헬퍼 함수: bytes32를 문자열로 변환
    // function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
    //     uint8 i = 0;
    //     while(i < 32 && _bytes32[i] != 0) {
    //         i++;
    //     }
    //     bytes memory bytesArray = new bytes(i);
    //     for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
    //         bytesArray[i] = _bytes32[i];
    //     }
    //     return string(bytesArray);
    // }

    // // 헬퍼 함수: uint를 문자열로 변환
    // function uintToString(uint v) internal pure returns (string memory str) {
    //     uint maxlength = 100;
    //     bytes memory reversed = new bytes(maxlength);
    //     uint i = 0;
    //     while (v != 0) {
    //         uint remainder = v % 10;
    //         v = v / 10;
    //         reversed[i++] = bytes1(uint8(48 + remainder));
    //     }
    //     bytes memory s = new bytes(i);
    //     for (uint j = 0; j < i; j++) {
    //         s[j] = reversed[i - j - 1];
    //     }
    //     str = string(s);
    // }

    // // 헬퍼 함수: address를 문자열로 변환
    // function toAsciiString(address x) internal pure returns (string memory) {
    //     bytes memory s = new bytes(40);
    //     for (uint i = 0; i < 20; i++) {
    //         bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
    //         bytes1 hi = bytes1(uint8(b) / 16);
    //         bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
    //         s[2*i] = char(hi);
    //         s[2*i+1] = char(lo);            
    //     }
    //     return string(s);
    // }

    // function char(bytes1 b) internal pure returns (bytes1 c) {
    //     if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
    //     else return bytes1(uint8(b) + 0x57);
    // }

}
