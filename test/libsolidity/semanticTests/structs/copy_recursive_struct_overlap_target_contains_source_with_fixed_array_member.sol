contract C {
    struct Node {
        Node[] children;
        uint256[3] fixedArr;
        uint256 balance;
    }

    Node root;

    function f() external returns (uint256 elem0, uint256 elem1, uint256 elem2, uint256 targetBalance, uint256 targetChildCount) {
        root.children.push();
        root.children[0].fixedArr[0] = 1;
        root.children[0].fixedArr[1] = 2;
        root.children[0].fixedArr[2] = 3;
        root.children[0].balance = 42;

        root = root.children[0];

        elem0 = root.fixedArr[0];
        elem1 = root.fixedArr[1];
        elem2 = root.fixedArr[2];
        targetBalance = root.balance;
        targetChildCount = root.children.length;
    }
}
// ----
// f() -> 1, 2, 3, 42, 0
// gas irOptimized: 181900
// gas legacy: 188855
// gas legacyOptimized: 182156
// gas ssaCFGOptimized: 181931
