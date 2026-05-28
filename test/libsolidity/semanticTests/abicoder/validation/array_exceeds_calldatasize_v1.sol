pragma abicoder v1;

contract C {
	function f(uint[] calldata) public {}
}
// ====
// ABIEncoderV1Only: true
// compileViaYul: false
// revertStrings: debug
// ----
// f(uint256[]): 0x20, 0 ->
// f(uint256[]): 0x20, 1 -> FAILURE, hex"08c379a0", 0x20, 43, "ABI calldata decoding: invalid d", "ata pointer"
// f(uint256[]): 0x20, 2 -> FAILURE, hex"08c379a0", 0x20, 43, "ABI calldata decoding: invalid d", "ata pointer"
