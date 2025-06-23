// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/Create2.sol";
import "./Wallet.sol";

/**
 * @title WalletFactory
 * @notice 스마트 월렛을 생성하는 팩토리 컨트랙트
 */
contract WalletFactory {
    /// @notice 새로운 월렛이 생성될 때 발생하는 이벤트
    event WalletCreated(address indexed owner, address wallet, bytes32 salt);

    /**
     * @notice 새로운 월렛을 생성하는 함수
     * @param owner 월렛의 소유자 주소
     * @param tokenRegistry 토큰 레지스트리 주소
     * @param entryPoint EntryPoint 컨트랙트 주소
     * @param salt CREATE2를 위한 솔트 값
     * @return wallet 생성된 월렛의 주소
     */
    function createWallet(
        address owner,
        address tokenRegistry,
        address entryPoint,
        bytes32 salt
    ) external returns (address) {
        // 입력 검증 추가
        require(owner != address(0), "Invalid owner address");
        require(tokenRegistry != address(0), "Invalid tokenRegistry address");
        require(entryPoint != address(0), "Invalid entryPoint address");
        
        bytes memory creationCode = type(Wallet).creationCode;
        bytes memory bytecode = abi.encodePacked(creationCode, abi.encode(owner, tokenRegistry, entryPoint));

        // 예상되는 월렛 주소 계산
        address addr = Create2.computeAddress(salt, keccak256(bytecode));

        // 이미 배포된 주소가 존재하는 경우 에러 발생 (중복 생성 방지)
        require(addr.code.length == 0, "Wallet already exists");

        // CREATE2를 사용하여 월렛 배포
        address wallet = deploy(salt, bytecode);

        emit WalletCreated(owner, wallet, salt);

        return wallet;
    }

    /**
     * @notice CREATE2를 사용하여 스마트 월렛을 배포하는 내부 함수
     * @param salt CREATE2를 위한 솔트 값
     * @param bytecode 배포할 컨트랙트의 바이트 코드
     * @return addr 배포된 컨트랙트의 주소
     */
    function deploy(bytes32 salt, bytes memory bytecode) internal returns (address addr) {
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        /// @solidity memory-safe-assembly
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
    }

    /**
     * @notice 특정 솔트 값으로 배포될 월렛의 예상 주소를 계산하는 함수
     * @param owner 월렛의 소유자 주소
     * @param tokenRegistry 토큰 레지스트리 주소
     * @param entryPoint EntryPoint 컨트랙트 주소
     * @param salt CREATE2를 위한 솔트 값
     * @return predictedAddress 예상되는 월렛 주소
     */
    function predictWalletAddress(
        address owner,
        address tokenRegistry,
        address entryPoint,
        bytes32 salt
    ) external view returns (address predictedAddress) {
        bytes memory creationCode = type(Wallet).creationCode;
        bytes memory bytecode = abi.encodePacked(creationCode, abi.encode(owner, tokenRegistry, entryPoint));
        predictedAddress = Create2.computeAddress(salt, keccak256(bytecode));
    }
}
