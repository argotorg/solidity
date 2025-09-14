contract C {
    struct Node {
        uint256 value;
        Node[] children;
    }

    function f() public pure returns (bool) {
        return type(Node).typehash == keccak256("Node(uint256 value,Node[] children)");
    }
}
// ----
// f() -> true