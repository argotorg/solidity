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
        uint256 thirdChildBalance,
        uint256 firstGrandchildBalance,
        uint256 secondGrandchildBalance,
        uint256 thirdGrandchildBalance
    ) {
        root.children.push();
        root.children[0].balance = 7;
        root.children[0].children.push();
        root.children[0].children.push();
        root.children[0].children.push();
        root.children[0].children[0].balance = 8;
        root.children[0].children[1].balance = 9;
        root.children[0].children[2].balance = 10;
        root.children[0].children[0].children.push();
        root.children[0].children[0].children.push();
        root.children[0].children[0].children.push();
        root.children[0].children[0].children[0].balance = 11;
        root.children[0].children[0].children[1].balance = 12;
        root.children[0].children[0].children[2].balance = 13;

        root = root.children[0];

        targetBalance = root.balance;
        targetChildCount = root.children.length;
        firstChildBalance = root.children[0].balance;
        secondChildBalance = root.children[1].balance;
        thirdChildBalance = root.children[2].balance;
        firstGrandchildBalance = root.children[0].children[0].balance;
        secondGrandchildBalance = root.children[0].children[1].balance;
        thirdGrandchildBalance = root.children[0].children[2].balance;
    }
}
// ----
// f() -> 7, 3, 8, 9, 10, 11, 12, 13
// gas irOptimized: 274687
// gas legacy: 288039
// gas legacyOptimized: 273930
// gas ssaCFGOptimized: 275057
