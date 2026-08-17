pragma abicoder v2;

contract C {
    struct S {
        uint256 a;      // slot 0 (bytes 0-31)
        uint128 b;      // slot 1 (bytes 0-15)
        uint64 c;       // slot 1 (bytes 16-23)
        bytes32 d;      // slot 2 (bytes 0-31)
        bool e;         // slot 3 (byte 0)
        // Total: 4 slots per struct
    }

    struct Canary {
        uint256 value;
    }

    function getBoundaryArray() internal pure returns (S[10][1] storage arr) {
        // 10 structs * 4 slots = 40 slots total
        // Starts at -20, ends at slot 19
        assembly {
            arr.slot := sub(0, 20)
        }
    }

    function getDest() internal pure returns (S[10][1] storage arr) {
        assembly {
            arr.slot := 21
        }
    }

    function getCanary() internal pure returns (Canary storage canary) {
        // Array ends at slot 19, canary at slot 20
        assembly {
            canary.slot := 20
        }
    }

    constructor() {
        Canary storage canary = getCanary();
        canary.value = type(uint256).max;
    }

    function fillBoundaryArray() public {
        S[10][1] storage arr = getBoundaryArray();
        for (uint i = 0; i < 10; i++) {
            arr[0][i] = S({
                a: 1 + i * 5,
                b: uint128(2 + i * 5),
                c: uint64(3 + i * 5),
                d: bytes32(uint256(4 + i * 5)),
                e: true
            });
        }
    }

    function deleteBoundaryArray() public {
        S[10][1] storage arr = getBoundaryArray();
        delete arr[0];
    }

    function copyFromBoundary() public {
        S[10][1] storage source = getBoundaryArray();
        S[10][1] storage dest = getDest();
        dest[0] = source[0];
    }

    function copyToBoundary() public {
        S[10][1] storage source = getDest();
        S[10][1] storage dest = getBoundaryArray();
        dest[0] = source[0];
    }

    function fillDestArray() public {
        S[10][1] storage dest = getDest();
        for (uint i = 0; i < 10; i++) {
            dest[0][i] = S({
                a: 51 + i * 5,
                b: uint128(52 + i * 5),
                c: uint64(53 + i * 5),
                d: bytes32(uint256(54 + i * 5)),
                e: true
            });
        }
    }

    function boundaryArray() public view returns (S[10] memory) {
        return getBoundaryArray()[0];
    }

    function destArray() public view returns (S[10] memory) {
        return getDest()[0];
    }

    function canaryValue() public view returns (uint256) {
        return getCanary().value;
    }
}
// ----
// canaryValue() -> 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
// boundaryArray() -> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
// gas irOptimized: 113181
// gas legacy: 123382
// gas legacyOptimized: 113519
// gas ssaCFGOptimized: 113261
// destArray() -> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
// gas irOptimized: 113090
// gas legacy: 123378
// gas legacyOptimized: 113517
// gas ssaCFGOptimized: 113170
// fillBoundaryArray()
// gas irOptimized: 913558
// gas legacy: 935528
// gas legacyOptimized: 918238
// gas ssaCFGOptimized: 916473
// canaryValue() -> 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
// boundaryArray() -> 1, 2, 3, 4, true, 6, 7, 8, 9, true, 11, 12, 13, 14, true, 16, 17, 18, 19, true, 21, 22, 23, 24, true, 26, 27, 28, 29, true, 31, 32, 33, 34, true, 36, 37, 38, 39, true, 41, 42, 43, 44, true, 46, 47, 48, 49, true
// gas irOptimized: 113181
// gas legacy: 123382
// gas legacyOptimized: 113519
// gas ssaCFGOptimized: 113261
// destArray() -> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
// gas irOptimized: 113090
// gas legacy: 123378
// gas legacyOptimized: 113517
// gas ssaCFGOptimized: 113170
// copyFromBoundary()
// gas irOptimized: 994627
// gas legacy: 1023887
// gas legacyOptimized: 994938
// gas ssaCFGOptimized: 996336
// canaryValue() -> 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
// boundaryArray() -> 1, 2, 3, 4, true, 6, 7, 8, 9, true, 11, 12, 13, 14, true, 16, 17, 18, 19, true, 21, 22, 23, 24, true, 26, 27, 28, 29, true, 31, 32, 33, 34, true, 36, 37, 38, 39, true, 41, 42, 43, 44, true, 46, 47, 48, 49, true
// gas irOptimized: 113181
// gas legacy: 123382
// gas legacyOptimized: 113519
// gas ssaCFGOptimized: 113261
// destArray() -> 1, 2, 3, 4, true, 6, 7, 8, 9, true, 11, 12, 13, 14, true, 16, 17, 18, 19, true, 21, 22, 23, 24, true, 26, 27, 28, 29, true, 31, 32, 33, 34, true, 36, 37, 38, 39, true, 41, 42, 43, 44, true, 46, 47, 48, 49, true
// gas irOptimized: 113090
// gas legacy: 123378
// gas legacyOptimized: 113517
// gas ssaCFGOptimized: 113170
// fillDestArray()
// gas irOptimized: 201462
// gas legacy: 223546
// gas legacyOptimized: 206258
// gas ssaCFGOptimized: 204347
// canaryValue() -> 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
// boundaryArray() -> 1, 2, 3, 4, true, 6, 7, 8, 9, true, 11, 12, 13, 14, true, 16, 17, 18, 19, true, 21, 22, 23, 24, true, 26, 27, 28, 29, true, 31, 32, 33, 34, true, 36, 37, 38, 39, true, 41, 42, 43, 44, true, 46, 47, 48, 49, true
// gas irOptimized: 113181
// gas legacy: 123382
// gas legacyOptimized: 113519
// gas ssaCFGOptimized: 113261
// destArray() -> 51, 52, 53, 54, true, 56, 57, 58, 59, true, 61, 62, 63, 64, true, 66, 67, 68, 69, true, 71, 72, 73, 74, true, 76, 77, 78, 79, true, 81, 82, 83, 84, true, 86, 87, 88, 89, true, 91, 92, 93, 94, true, 96, 97, 98, 99, true
// gas irOptimized: 113090
// gas legacy: 123378
// gas legacyOptimized: 113517
// gas ssaCFGOptimized: 113170
// copyToBoundary()
// gas irOptimized: 282671
// gas legacy: 311842
// gas legacyOptimized: 282904
// gas ssaCFGOptimized: 284380
// canaryValue() -> 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
// boundaryArray() -> 51, 52, 53, 54, true, 56, 57, 58, 59, true, 61, 62, 63, 64, true, 66, 67, 68, 69, true, 71, 72, 73, 74, true, 76, 77, 78, 79, true, 81, 82, 83, 84, true, 86, 87, 88, 89, true, 91, 92, 93, 94, true, 96, 97, 98, 99, true
// gas irOptimized: 113181
// gas legacy: 123382
// gas legacyOptimized: 113519
// gas ssaCFGOptimized: 113261
// destArray() -> 51, 52, 53, 54, true, 56, 57, 58, 59, true, 61, 62, 63, 64, true, 66, 67, 68, 69, true, 71, 72, 73, 74, true, 76, 77, 78, 79, true, 81, 82, 83, 84, true, 86, 87, 88, 89, true, 91, 92, 93, 94, true, 96, 97, 98, 99, true
// gas irOptimized: 113090
// gas legacy: 123378
// gas legacyOptimized: 113517
// gas ssaCFGOptimized: 113170
// deleteBoundaryArray()
// gas irOptimized: 177828
// gas legacy: 181180
// gas legacyOptimized: 178259
// gas ssaCFGOptimized: 177848
// canaryValue() -> 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
// boundaryArray() -> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
// gas irOptimized: 113181
// gas legacy: 123382
// gas legacyOptimized: 113519
// gas ssaCFGOptimized: 113261
// destArray() -> 51, 52, 53, 54, true, 56, 57, 58, 59, true, 61, 62, 63, 64, true, 66, 67, 68, 69, true, 71, 72, 73, 74, true, 76, 77, 78, 79, true, 81, 82, 83, 84, true, 86, 87, 88, 89, true, 91, 92, 93, 94, true, 96, 97, 98, 99, true
// gas irOptimized: 113090
// gas legacy: 123378
// gas legacyOptimized: 113517
// gas ssaCFGOptimized: 113170
