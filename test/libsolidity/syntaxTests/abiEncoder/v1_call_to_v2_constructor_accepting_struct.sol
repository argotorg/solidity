==== Source: A ====
pragma abicoder               v2;

contract C {
    struct Item {
        uint x;
    }

    constructor(Item memory _item) {}
}
==== Source: B ====
pragma abicoder v1;
import "A";

contract Test {
    function foo() public {
        new C(C.Item(5));
    }
}
// ----
// Warning 9511: (B:0-19): ABI coder v1 is deprecated and scheduled for removal. Use ABI coder v2 instead.
// TypeError 2443: (B:91-100): The type of this parameter, struct C.Item memory, is only supported in ABI coder v2. Use "pragma abicoder v2;" to enable the feature.
