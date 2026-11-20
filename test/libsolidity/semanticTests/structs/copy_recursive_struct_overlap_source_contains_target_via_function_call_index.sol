contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;

    function f() external returns (
        uint256 targetBalance,
        uint256 targetChildCount,
        uint256 targetGrandchildBalance
    ) {
        root.children.push();
        root.children[0].balance = 11;
        root.children[0].children.push();
        root.children[0].children[0].balance = 22;

        // Source contains the target, reached through a function-call index. This
        // source-contains-target direction is unsupported and its behavior is undefined.
        // Here it reverts.
        root.children[zero()].children[zero()] = root.children[zero()];

        targetBalance = root.children[0].children[0].balance;
        targetChildCount = root.children[0].children[0].children.length;
        if (targetChildCount > 0)
            targetGrandchildBalance = root.children[0].children[0].children[0].balance;
    }

    function zero() internal pure returns (uint256) { return 0; }
}
// ----
// f() -> FAILURE
// gas irOptimized: 100000000
// gas legacy: 100000000
// gas legacyOptimized: 100000000
// gas ssaCFGOptimized: 100000000
