contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node root;

    function f() external returns (
        uint256 targetBalance,
        uint256 targetChildCount,
        uint256 firstChildBalance,
        uint256 secondChildBalance,
        uint256 firstGrandchildBalance
    ) {
        root.balance = 1;
        root.children.push();
        root.children.push();
        root.children[0].balance = 42;
        root.children[1].balance = 99;
        root.children[0].children.push();
        root.children[0].children[0].balance = 111;
        root.children[0].children.push();
        root.children[0].children[1].balance = 222;
        root.children[0].children[0].children.push();
        root.children[0].children[0].children[0].balance = 1111;

        root = root.children[0];

        targetBalance = root.balance;
        targetChildCount = root.children.length;
        firstChildBalance = root.children[0].balance;
        secondChildBalance = root.children[1].balance;
        firstGrandchildBalance = root.children[0].children[0].balance;
    }
}
// ----
// f() -> 42, 2, 111, 222, 1111
// gas irOptimized: 190864
// gas legacy: 199456
// gas legacyOptimized: 190072
// gas ssaCFGOptimized: 190895
