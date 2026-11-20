contract C {
    struct NodeA {
        NodeB[3] children;
        uint256 balance;
    }
    struct NodeB {
        NodeA[] inner;
    }

    NodeA root;

    // The recursion routes through a fixed array (NodeA -> NodeB[3] -> NodeB -> NodeA[] -> NodeA).
    function f() external returns (
        uint256 targetBalance,
        uint256 targetInnerCount,
        uint256 firstInnerBalance,
        uint256 secondInnerBalance
    ) {
        root.balance = 1;
        root.children[0].inner.push();

        // Build the source subtree at root.children[0].inner[0] (a NodeA).
        root.children[0].inner[0].balance = 42;
        root.children[0].inner[0].children[0].inner.push();
        root.children[0].inner[0].children[0].inner.push();
        root.children[0].inner[0].children[0].inner[0].balance = 8;
        root.children[0].inner[0].children[0].inner[1].balance = 9;

        root = root.children[0].inner[0];

        targetBalance = root.balance;
        targetInnerCount = root.children[0].inner.length;
        firstInnerBalance = root.children[0].inner[0].balance;
        secondInnerBalance = root.children[0].inner[1].balance;
    }
}
// ----
// f() -> 42, 2, 8, 9
// gas irOptimized: 175198
// gas legacy: 192638
// gas legacyOptimized: 175365
// gas ssaCFGOptimized: 174985
