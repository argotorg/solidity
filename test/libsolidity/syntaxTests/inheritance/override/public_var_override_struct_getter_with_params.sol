interface I {
    struct S {
        uint a;
        uint[] array;
    }
    function m(uint) external view returns (S memory);
    function list(uint) external view returns (S memory);
}

contract C is I {
    mapping(uint => S) public override m;
    S[] public override list;
}
// ----
