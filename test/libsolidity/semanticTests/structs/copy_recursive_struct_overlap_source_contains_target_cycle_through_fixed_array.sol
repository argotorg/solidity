contract C {
    struct NodeA {
        NodeB[3] children;
        uint256 balance;
    }
    struct NodeB {
        NodeA[] inner;
    }

    NodeA root;

    function f() external {
        root.children[0].inner.push();
        root.children[0].inner[0].children[0].inner.push();

        // The source (root.children[0].inner[0]) contains the target
        // (root.children[0].inner[0].children[0].inner[0]), reached through a function-call index.
        // This direction is unsupported and its behavior is undefined. Here it reverts. The overlap
        // handling routes through a fixed array (NodeA -> NodeB[3] -> NodeB -> NodeA[] -> NodeA).
        root.children[0].inner[zero()].children[0].inner[zero()] = root.children[0].inner[zero()];
    }

    function zero() internal pure returns (uint256) { return 0; }
}
// ----
// f() -> FAILURE
