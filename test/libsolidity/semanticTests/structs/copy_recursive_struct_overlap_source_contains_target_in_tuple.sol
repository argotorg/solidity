contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;
    uint256 other;

    function f() external returns (uint256 targetBalance, uint256 targetChildCount) {
        root.children.push();
        root.children[0].balance = 11;
        root.children[0].children.push();
        root.children[0].children[0].balance = 22;

        // A source-contains-target overlap hidden in a tuple component. This direction is
        // unsupported and its behavior is undefined. Here it reverts.
        (root.children[zero()].children[zero()], other) = (root.children[zero()], 1);

        targetBalance = root.children[0].children[0].balance;
        targetChildCount = root.children[0].children[0].children.length;
    }

    function zero() internal pure returns (uint256) { return 0; }
}
// ----
// f() -> FAILURE
// gas irOptimized: 100000000
// gas legacy: 100000000
// gas legacyOptimized: 100000000
// gas ssaCFGOptimized: 100000000
