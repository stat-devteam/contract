// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@account-abstraction/contracts/interfaces/UserOperation.sol";
import "@account-abstraction/contracts/interfaces/IAccount.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./TokenRegistry.sol";
import "./STATLockUp.sol";



/**
 * @title Wallet
 * @dev 스마트 계정으로 기능을 수행하는 컨트랙트
 */
contract Wallet is IAccount, ReentrancyGuard {
    using ECDSA for bytes32;

    address public owner;
    address public immutable tokenRegistry; // TokenRegistry 컨트랙트 주소
    address public entryPoint;  // EntryPoint 컨트랙트 주소

    event ApprovalGranted(address token, address spender, uint256 amount);
    event TokenTransferred(address indexed token, address indexed recipient, uint256 amount);
    event Executed(address indexed to, bytes data);
    event EntryPointUpdated(address newEntryPoint);
    event TransactionFailed(address indexed target, bytes data);

    /**
     * @dev 컨트랙트 생성자
     * @param _owner 지갑 소유자 주소
     * @param _tokenRegistry TokenRegistry 컨트랙트 주소
     * @param _entryPoint EntryPoint 컨트랙트 주소
     */
    constructor(address _owner, address _tokenRegistry, address _entryPoint) {
        require(_owner != address(0), "Invalid owner address");
        require(_tokenRegistry != address(0), "Invalid tokenRegistry address");
        require(_entryPoint != address(0), "Invalid entryPoint address");
        owner = _owner;
        tokenRegistry = _tokenRegistry;
        entryPoint = _entryPoint;
    }

    /**
     * @dev 소유자를 변경하는 함수
     * @param newOwner 새로운 소유자 주소
     */
    function changeOwner(address newOwner) external {
        require(msg.sender == owner, "Not authorized");
        require(newOwner != address(0), "Invalid address");
        require(newOwner != owner, "New owner must be different from current owner");
        owner = newOwner;
    }

    /**
     * @dev EntryPoint 주소를 업데이트하는 함수
     * @param newEntryPoint 새로운 EntryPoint 컨트랙트 주소
     */
    function updateEntryPoint(address newEntryPoint) external {
        require(msg.sender == owner, "Not authorized");
        require(newEntryPoint != address(0), "Invalid EntryPoint address");
        require(newEntryPoint.code.length > 0, "Invalid contract address");

        entryPoint = newEntryPoint;
        emit EntryPointUpdated(newEntryPoint);
    }

    /**
     * @dev 지갑의 ETH 잔액을 조회
     * @return ETH 잔액
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev 특정 ERC20 토큰의 잔액을 조회
     * @param tokenAddress 조회할 ERC20 토큰 주소
     * @return 토큰 잔액
     */
    function getTokenBalance(address tokenAddress) external view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    /**
     * @dev UserOperation 서명을 검증하는 함수
     */
    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256
    ) external view override returns (uint256 validationData) {
        require(msg.sender == entryPoint, "Only EntryPoint can call");

        // // EIP-191 prefix 적용된 서명 해시 생성
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        address recovered = ECDSA.recover(ethSignedMessageHash, userOp.signature);

        return owner == recovered ? 0 : 1;
    }

    /**
     * @dev 특정 주소에 토큰 전송을 승인하는 함수
     * @param spender 승인 대상 주소
     * @param amount 승인할 토큰 수량
     */
    function approveToken(address spender, uint256 amount) external nonReentrant {
        require(msg.sender == entryPoint || msg.sender == owner, "Not authorized");
        address token = TokenRegistry(tokenRegistry).getToken();
        require(token != address(0), "Invalid token address");
        IERC20(token).approve(spender, amount);
        emit ApprovalGranted(token, spender, amount);
    }

    /**
     * @dev 특정 주소로 토큰을 전송하는 함수
     * @param recipient 수신자 주소
     * @param amount 전송할 토큰 수량
     */
    function transferToken(address recipient, uint256 amount) external nonReentrant {
        require(msg.sender == entryPoint || msg.sender == owner, "Not authorized");
        address token = TokenRegistry(tokenRegistry).getToken();
        require(token != address(0), "Invalid token address");
        require(IERC20(token).transfer(recipient, amount), "Token transfer failed");
        emit TokenTransferred(token, recipient, amount);
    }
    
    /**
     * @dev LockUp 컨트랙트로 토큰을 전송하는 함수
     */
    function transferToLockUp(address lockupContract) external nonReentrant {
        require(msg.sender == entryPoint || msg.sender == owner, "Not authorized");
        require(lockupContract != address(0), "Invalid lockup contract");
        require(lockupContract.code.length > 0, "Lockup contract must be a contract");
        
        // 추가 보안: lockupContract가 실제 STATLockUp인지 검증
        // tokenRegistry 주소를 확인
        try STATLockUp(lockupContract).tokenRegistry() returns (address contractTokenRegistry) {
            require(contractTokenRegistry == tokenRegistry, "Token registry mismatch");
        } catch {
            revert("Invalid STATLockUp contract");
        }
        
        uint256 amount = STATLockUp(lockupContract).requiredLockupAmount();
        address token = TokenRegistry(tokenRegistry).getToken();
        require(token != address(0), "Invalid token address");

        IERC20(token).approve(lockupContract, amount);
        STATLockUp(lockupContract).statLockup();
    }

    /**
     * @dev 단일 트랜잭션 실행 함수
     */
    function execute(address to, uint256 value, bytes calldata data) external nonReentrant {
        require(msg.sender == entryPoint || msg.sender == owner, "Not authorized");
        (bool success, ) = to.call{value: value}(data);
        if (!success) {
            emit TransactionFailed(to, data);
        }
        require(success, "Execution failed");
        emit Executed(to, data);
    }

    /**
     * @dev 여러 트랜잭션을 한 번에 실행하는 함수
     */
    function executeBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas
    ) external nonReentrant {
        require(msg.sender == entryPoint || msg.sender == owner, "Not authorized");
        require(targets.length == values.length && values.length == datas.length, "Mismatched inputs");
        require(targets.length > 0, "No transactions to execute");
        
        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, ) = address(targets[i]).call{value: values[i]}(datas[i]);
            if (!success) {
                emit TransactionFailed(targets[i], datas[i]);
            } else {
                emit Executed(targets[i], datas[i]);
            }
        }
    }

    receive() external payable {}
}