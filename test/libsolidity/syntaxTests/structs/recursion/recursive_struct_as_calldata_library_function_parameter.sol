pragma abicoder v2;

library L {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    function f(Node calldata _x) public {
    }
}
// ----
// TypeError 4103: (123-139): Recursive structs can only be passed as storage pointers to libraries, not as memory objects to contract functions.
