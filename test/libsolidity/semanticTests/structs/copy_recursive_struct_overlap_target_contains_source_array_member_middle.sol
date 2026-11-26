contract C {
    struct Node {
        uint256 low;
        Node[] children;
        uint256 high;
    }

    Node root;

    function f() external returns (
        uint256 targetLow,
        uint256 targetHigh,
        uint256 targetChildCount,
        uint256 firstChildLow,
        uint256 firstChildHigh,
        uint256 secondChildLow,
        uint256 secondChildHigh
    ) {
        root.children.push();
        root.children[0].low = 1;
        root.children[0].high = 2;
        root.children[0].children.push();
        root.children[0].children.push();
        root.children[0].children[0].low = 3;
        root.children[0].children[0].high = 4;
        root.children[0].children[1].low = 5;
        root.children[0].children[1].high = 6;

        root = root.children[0];

        targetLow = root.low;
        targetHigh = root.high;
        targetChildCount = root.children.length;
        firstChildLow = root.children[0].low;
        firstChildHigh = root.children[0].high;
        secondChildLow = root.children[1].low;
        secondChildHigh = root.children[1].high;
    }
}
// ----
// f() -> 1, 2, 2, 3, 4, 5, 6
// gas irOptimized: 242544
// gas legacy: 252324
// gas legacyOptimized: 242434
// gas ssaCFGOptimized: 242742
