contract C {
    struct Node {
        uint256 head;
        Node[] a;
        uint256 mid;
        Node[] b;
    }

    Node root;

    function f() external returns (
        uint256 targetHead,
        uint256 targetMid,
        uint256 targetACount,
        uint256 firstChildHead
    ) {
        root.a.push();
        root.a[0].head = 111;
        root.a[0].mid = 222;
        root.a[0].a.push();
        root.a[0].a[0].head = 333;

        root = root.a[0];

        targetHead = root.head;
        targetMid = root.mid;
        targetACount = root.a.length;
        firstChildHead = root.a[0].head;
    }
}
// ----
// f() -> 111, 222, 1, 333
// gas irOptimized: 155101
// gas legacy: 162769
// gas legacyOptimized: 155036
// gas ssaCFGOptimized: 155088
