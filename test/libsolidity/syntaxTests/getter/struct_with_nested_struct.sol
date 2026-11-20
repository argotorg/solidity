contract C {
    struct T {
        uint x;
        uint[] array;
    }
    struct S {
        uint a;
        uint[] array;
        T t;
    }
    S public s;

    function f() external view {
        function () external view returns (uint, T memory) asTuple = this.s;
        function () external view returns (S memory) asStruct = this.s;
        asTuple;
        asStruct;
    }
}
// ----
// TypeError 9574: (279-341): Type function () view external returns (uint256,struct C.T memory) is not implicitly convertible to expected type function () view external returns (struct C.S memory).
