interface I {
    struct S {
        uint a;
    }
    function s() external view returns (S memory);
}

contract C is I {
    struct WrappedS {
        S s;
    }
    WrappedS public override s;
}
// ----
