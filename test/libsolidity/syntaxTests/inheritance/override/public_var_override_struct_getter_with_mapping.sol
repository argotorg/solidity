interface I {
    function s() external view returns (uint);
}

contract C is I {
    struct S {
        uint a;
        mapping(uint => uint) m;
    }
    S public override s;
}
// ----
// TypeError 4822: (156-175): Overriding public state variable return types differ.
// TypeError 6744: (156-175): Internal or recursive type is not allowed for public state variables.
