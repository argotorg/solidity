contract C {
    struct Node {
        Node[] children;
        bytes data;
    }

    Node root;

    function f() external returns (uint256 targetDataLength, uint256 targetChildCount, uint256 childDataLength) {
        root.children.push();
        root.children[0].data = "hello";
        root.children[0].children.push();
        root.children[0].children[0].data = "hi";

        root = root.children[0];

        targetDataLength = root.data.length;             // 5   ("hello")
        targetChildCount = root.children.length;         // 1
        childDataLength = root.children[0].data.length;  // 2   ("hi")
    }
}
// ----
// f() -> 5, 1, 2
// gas irOptimized: 113291
// gas legacy: 117929
// gas legacyOptimized: 113620
// gas ssaCFGOptimized: 113196
