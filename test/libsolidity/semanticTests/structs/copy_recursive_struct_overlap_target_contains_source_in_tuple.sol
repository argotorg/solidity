contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;
    uint256 other;

    function f() external returns (uint256 targetBalance, uint256 targetChildCount, uint256 targetChildBalance) {
        root.children.push();
        root.children[0].balance = 11;
        root.children[0].children.push();
        root.children[0].children.push();
        root.children[0].children[0].balance = 22;

        (root, other) = (root.children[0], 1);

        targetBalance = root.balance;
        targetChildCount = root.children.length;
        targetChildBalance = root.children[0].balance;
    }
}
// ----
// f() -> 11, 2, 22
// gas irOptimized: 137331
// gas legacy: 143834
// gas legacyOptimized: 136963
// gas ssaCFGOptimized: 137320
