interface I {
    struct T {
        uint x;
        uint[] array;
    }
    struct S {
        uint a;
        uint[] dynamicArray;
        uint[3] staticArray;
        bytes b;
        T t;
    }
    function s() external view returns (S memory);
}

contract C is I {
    S public override s;
}
// ----
