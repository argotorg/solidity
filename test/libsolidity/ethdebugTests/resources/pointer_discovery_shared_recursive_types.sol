struct Node {
    uint256 value;
    Node[] children;
}

contract A {
    Node single;
    Node[] many;
}

contract B {
    uint128 padding;
    Node[] many;
    Node single;
}
// ----
// .resources.types | length: 4
// .resources.pointers | length: 4
