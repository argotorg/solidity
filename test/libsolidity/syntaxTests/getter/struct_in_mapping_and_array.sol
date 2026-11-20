contract C {
    struct S {
        uint a;
        uint[] array;
    }
    mapping(uint => S) public m;
    S[] public list;

    function f() external view {
        function (uint) external view returns (uint) mAsTuple = this.m;
        function (uint) external view returns (S memory) mAsStruct = this.m;
        function (uint) external view returns (uint) listAsTuple = this.list;
        function (uint) external view returns (S memory) listAsStruct = this.list;
    }
}
// ----
// TypeError 9574: (240-307): Type function (uint256) view external returns (uint256) is not implicitly convertible to expected type function (uint256) view external returns (struct C.S memory).
// TypeError 9574: (395-468): Type function (uint256) view external returns (uint256) is not implicitly convertible to expected type function (uint256) view external returns (struct C.S memory).
