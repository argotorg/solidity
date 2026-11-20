contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node[] roots;

    // The source array contains the target, so the copy fails.
    function sneakyAssign(Node[] storage source) internal {
        roots[0].children = source;
    }

    function f() external {
        roots.push();
        roots[0].balance = 11;
        sneakyAssign(roots);
    }
}
// ----
// f() -> FAILURE
