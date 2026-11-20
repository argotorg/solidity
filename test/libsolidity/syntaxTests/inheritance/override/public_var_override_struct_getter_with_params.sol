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
// TypeError 4822: (211-247): Overriding public state variable return types differ.
// TypeError 4822: (253-277): Overriding public state variable return types differ.
