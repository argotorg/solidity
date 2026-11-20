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
    function s() external view returns (uint, bytes memory, T memory);
}

contract C is I {
    S public override s;
}
// ----
