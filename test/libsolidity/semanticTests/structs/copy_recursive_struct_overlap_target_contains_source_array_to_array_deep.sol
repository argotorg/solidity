contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node[] roots;

    function f() external returns (uint256 targetLength, uint256 firstBalance, uint256 secondBalance) {
        roots.push();
        roots[0].children.push();
        roots[0].children[0].children.push();
        roots[0].children[0].children.push();
        roots[0].children[0].children[0].balance = 11;
        roots[0].children[0].children[1].balance = 22;

        roots = roots[0].children[0].children;   // deep array-to-array overlap

        targetLength = roots.length;
        firstBalance = roots[0].balance;
        secondBalance = roots[1].balance;
    }
}
// ----
// f() -> 2, 11, 22
// gas irOptimized: 155360
// gas legacy: 161757
// gas legacyOptimized: 154715
// gas ssaCFGOptimized: 155308
