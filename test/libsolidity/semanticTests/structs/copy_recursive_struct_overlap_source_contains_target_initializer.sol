contract C {
    struct Node {
        Node[] children;
        uint256[] values;
    }

    Node root = grow();

    function grow() internal returns (Node storage) {
        root.children.push();
        root.children[0].values.push(111);
        root.children[0].values.push(222);
        return root.children[0];
    }

    function f() external view returns (uint256 valueCount, uint256 firstValue, uint256 secondValue) {
        valueCount = root.values.length;
        firstValue = root.values[0];
        secondValue = root.values[1];
    }
}
// ----
// f() -> 2, 111, 222
