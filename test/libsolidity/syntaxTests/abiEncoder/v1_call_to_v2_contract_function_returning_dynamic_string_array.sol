==== Source: A ====
pragma abicoder               v2;

contract C {
    function f() external view returns (string[] memory) {}
}
==== Source: B ====
pragma abicoder v1;
import "A";

contract D {
    function g() public view {
        C(address(0x00)).f();
    }
}
// ----
// Warning 9511: (B:0-19): ABI coder v1 is deprecated and scheduled for removal. Use ABI coder v2 instead.
// TypeError 2428: (B:85-105): The type of return parameter 1, string[] memory, is only supported in ABI coder v2. Use "pragma abicoder v2;" to enable the feature.
