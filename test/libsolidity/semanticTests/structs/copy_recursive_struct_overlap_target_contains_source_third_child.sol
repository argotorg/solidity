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
        uint256 secondChildBalance
    ) {
        root.children.push();
        root.children.push();
        root.children.push();
        root.children[0].balance = 10;
        root.children[1].balance = 20;
        root.children[2].balance = 30;
        root.children[2].children.push();
        root.children[2].children[0].balance = 300;
        root.children[2].children.push();
        root.children[2].children[1].balance = 301;

        root = root.children[2];

        targetBalance = root.balance;
        targetChildCount = root.children.length;
        firstChildBalance = root.children[0].balance;
        secondChildBalance = root.children[1].balance;
    }
}
// ----
// f() -> 30, 2, 300, 301
// gas irOptimized: 173200
// gas legacy: 180746
// gas legacyOptimized: 172165
// gas ssaCFGOptimized: 173211
