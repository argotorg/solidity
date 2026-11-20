contract C {
    struct NodeA {
        NodeB[] children;
        uint256 balance;
    }
    struct NodeB {
        NodeA inner;
    }

    NodeA root;

    // Mutual recursion: NodeA -> NodeB[] -> NodeB -> NodeA.
    function f() external returns (
        uint256 targetBalance,
        uint256 targetChildCount,
        uint256 firstChildInnerBalance,
        uint256 secondChildInnerBalance
    ) {
        root.balance = 1;
        root.children.push();
        root.children.push();
        root.children.push();

        // Build the source subtree at root.children[0].inner (a NodeA).
        root.children[0].inner.balance = 42;
        root.children[0].inner.children.push();
        root.children[0].inner.children.push();
        root.children[0].inner.children[0].inner.balance = 8;
        root.children[0].inner.children[1].inner.balance = 9;

        root = root.children[0].inner;

        targetBalance = root.balance;
        targetChildCount = root.children.length;
        firstChildInnerBalance = root.children[0].inner.balance;
        secondChildInnerBalance = root.children[1].inner.balance;
    }
}
// ----
// f() -> 42, 2, 8, 9
// gas irOptimized: 157072
// gas legacy: 165395
// gas legacyOptimized: 156017
// gas ssaCFGOptimized: 157032
