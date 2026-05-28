pragma abicoder v1;

contract C {
    function f(uint a, uint[] calldata b, uint c) external pure returns (uint) {
        return 7;
    }
}
// ====
// ABIEncoderV1Only: true
// compileViaYul: false
// revertStrings: debug
// ----
// f(uint256,uint256[],uint256): 6, 0x60, 9, 0x8000000000000000000000000000000000000000000000000000000000000002, 1, 2 -> FAILURE, hex"08c379a0", 0x20, 43, "ABI calldata decoding: invalid d", "ata pointer"
