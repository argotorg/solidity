contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node[] roots;

    function f() external returns (
        uint256 targetLength,
        uint256 firstBalance,
        uint256 secondBalance,
        uint256 firstChildCount,
        uint256 secondChildCount
    ) {
        roots.push();
        roots.push();
        roots.push();
        roots[2].children.push();
        roots[2].children.push();
        roots[2].children[0].balance = 11;
        roots[2].children[0].children.push();
        roots[2].children[1].balance = 22;
        roots[2].children[1].children.push();
        roots[2].children[1].children.push();

        roots = roots[2].children;

        targetLength = roots.length;
        firstBalance = roots[0].balance;
        secondBalance = roots[1].balance;
        firstChildCount = roots[0].children.length;
        secondChildCount = roots[1].children.length;
    }
}
// ----
// f() -> 2, 11, 22, 1, 2
// gas irOptimized: 228982
// gas legacy: 242228
// gas legacyOptimized: 227257
// gas ssaCFGOptimized: 228969
