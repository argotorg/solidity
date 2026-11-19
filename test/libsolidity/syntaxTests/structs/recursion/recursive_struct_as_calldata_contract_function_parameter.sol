pragma abicoder v2;

contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    function f(Node calldata _x) external {
    }
}
// ----
// TypeError 4103: (124-140): Recursive type not allowed for public or external contract functions.
