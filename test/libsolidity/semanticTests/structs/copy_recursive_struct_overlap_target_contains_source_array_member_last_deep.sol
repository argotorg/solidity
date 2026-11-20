contract C {
    struct Node {
        uint256 balance;
        Node[] children;
    }

    Node root;

    function f() external returns (
        uint256 targetBalance,
        uint256 targetChildCount,
        uint256 firstChildBalance,
        uint256 secondChildBalance,
        uint256 thirdChildBalance
    ) {
        root.children.push();
        root.children[0].balance = 111;
        root.children[0].children.push();
        root.children[0].children[0].balance = 222;
        root.children[0].children[0].children.push();
        root.children[0].children[0].children.push();
        root.children[0].children[0].children.push();
        root.children[0].children[0].children[0].balance = 1;
        root.children[0].children[0].children[1].balance = 2;
        root.children[0].children[0].children[2].balance = 3;

        root = root.children[0].children[0];

        targetBalance = root.balance;
        targetChildCount = root.children.length;
        firstChildBalance = root.children[0].balance;
        secondChildBalance = root.children[1].balance;
        thirdChildBalance = root.children[2].balance;
    }
}
// ----
// f() -> 222, 3, 1, 2, 3
// gas irOptimized: 231147
// gas legacy: 241046
// gas legacyOptimized: 230649
// gas ssaCFGOptimized: 231136
