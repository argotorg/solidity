contract C {
    struct S {
        uint a;
        uint[] dynamicArray;
        uint[3] staticArray;
        bytes b;
        string str;
    }
    S public s;

    function f() external view {
        function () external view returns (uint, bytes memory, string memory) asTuple = this.s;
        function () external view returns (S memory) asStruct = this.s;
        asTuple;
        asStruct;
    }
}
// ----
// TypeError 9574: (299-361): Type function () view external returns (uint256,bytes memory,string memory) is not implicitly convertible to expected type function () view external returns (struct C.S memory).
