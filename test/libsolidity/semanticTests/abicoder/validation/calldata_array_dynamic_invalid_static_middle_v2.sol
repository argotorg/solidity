pragma abicoder v2;

contract C {
    function f(uint256[][1][] calldata a) external returns (uint256) {
        return 42;
    }

    function g(uint256[][1][] calldata a) external returns (uint256) {
        a[0];
        return 42;
    }

    function h(uint256[][1][] calldata a) external returns (uint256) {
        a[0][0];
        return 42;
    }
}
// ====
// revertStrings: debug
// ----
// f(uint256[][1][]): 0x20, 0x0 -> 42 # valid access stub #
// f(uint256[][1][]): 0x20, 0x1 -> FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray stride" # invalid on argument decoding #
// f(uint256[][1][]): 0x20, 0x1, 0x20 -> 42 # invalid on outer access #
// g(uint256[][1][]): 0x20, 0x1, 0x20 -> FAILURE, hex"08c379a0", 0x20, 0x1c, "Invalid calldata tail offset"
// f(uint256[][1][]): 0x20, 0x1, 0x20, 0x20 -> 42 # invalid on inner access #
// g(uint256[][1][]): 0x20, 0x1, 0x20, 0x20 -> 42
// h(uint256[][1][]): 0x20, 0x1, 0x20, 0x20 -> FAILURE, hex"08c379a0", 0x20, 0x1c, "Invalid calldata tail offset"
// f(uint256[][1][]): 0x20, 0x1, 0x20, 0x20, 0x1 -> 42
// g(uint256[][1][]): 0x20, 0x1, 0x20, 0x20, 0x1 -> 42
// h(uint256[][1][]): 0x20, 0x1, 0x20, 0x20, 0x1 -> FAILURE, hex"08c379a0", 0x20, 0x17, "Calldata tail too short"
