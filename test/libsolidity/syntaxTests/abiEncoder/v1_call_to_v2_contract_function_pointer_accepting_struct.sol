==== Source: A ====
pragma abicoder               v2;

contract C {
    struct Item {
        uint x;
    }

    function get(Item memory _item) external {}
}
==== Source: B ====
pragma abicoder v1;
import "A";

contract Test {
    function foo() public {
        C c = new C();
        function(C.Item memory) external ptr = c.get;
        ptr(C.Item(5));
    }
}
// ----
// Warning 9511: (B:0-19): ABI coder v1 is deprecated and scheduled for removal. Use ABI coder v2 instead.
// TypeError 2443: (B:166-175): The type of this parameter, struct C.Item memory, is only supported in ABI coder v2. Use "pragma abicoder v2;" to enable the feature.
