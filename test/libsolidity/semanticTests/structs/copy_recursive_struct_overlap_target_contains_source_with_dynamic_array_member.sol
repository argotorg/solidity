contract C {
    struct Node {
        Node[] children;
        uint256[] values;
    }

    Node root;

    function f() external returns (uint256 valueCount, uint256 firstValue, uint256 secondValue) {
        root.children.push();
        root.children[0].values.push(111);
        root.children[0].values.push(222);

        root = root.children[0];

        valueCount = root.values.length;
        firstValue = root.values[0];
        secondValue = root.values[1];
    }
}
// ----
// f() -> 2, 111, 222
// gas irOptimized: 146940
// gas legacy: 151390
// gas legacyOptimized: 146651
// gas ssaCFGOptimized: 146947
