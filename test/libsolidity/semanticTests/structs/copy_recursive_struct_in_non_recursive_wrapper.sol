contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }
    struct Wrapper {
        Node node;
        uint256 tag;
    }

    Wrapper a;
    Wrapper b;

    function f() external returns (uint256 balance, uint256 childBalance, uint256 childCount, uint256 tag) {
        b.node.children.push();
        b.node.children[0].balance = 7;
        b.node.balance = 5;
        b.tag = 99;

        a = b;

        balance = a.node.balance;
        childBalance = a.node.children[0].balance;
        childCount = a.node.children.length;
        tag = a.tag;
    }
}
// ----
// f() -> 5, 7, 1, 99
// gas irOptimized: 204417
// gas legacy: 206160
// gas legacyOptimized: 204379
// gas ssaCFGOptimized: 204334
