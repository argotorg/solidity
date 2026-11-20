contract C {
    struct NodeA {
        NodeB[] children;
        uint256 balance;
    }
    struct NodeB {
        NodeA inner;
    }

    NodeA root;

    function f() external {
        root.children.push();
        root.children[0].inner.children.push();

        // The source (root.children[0].inner) contains the target
        // (root.children[0].inner.children[0].inner). This direction is unsupported and its
        // behavior is undefined. Here it reverts. This exercises a mutually recursive type
        // (NodeA through NodeB back to NodeA).
        root.children[zero()].inner.children[zero()].inner = root.children[zero()].inner;
    }

    function zero() internal pure returns (uint256) { return 0; }
}
// ----
// f() -> FAILURE
