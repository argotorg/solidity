pragma abicoder v2;

contract C {
    bytes[][] s1;
    bytes[][1] s2;
    bytes[1][] s3;

    function test1(bytes[][] calldata _a) public returns (bytes[][] memory) {
        s1 = _a;
        return s1;
    }

    function test2(bytes[][1] calldata _a) public returns (bytes[][1] memory) {
        s2 = _a;
        return s2;
    }

    function test3(bytes[1][] calldata _a) public returns (bytes[1][] memory) {
        s3 = _a;
        return s3;
    }
}
// ----
// test1(bytes[][]): 0x20, 2, 0x40, 0xc0, 1, 0x20, 5, "hello", 2, 0x40, 0x80, 5, "world", 3, "foo" -> 0x20, 2, 0x40, 0xc0, 1, 0x20, 5, "hello", 2, 0x40, 0x80, 5, "world", 3, "foo"
// gas irOptimized: 163059
// gas legacy: 167558
// gas legacyOptimized: 164068
// test2(bytes[][1]): 0x20, 0x20, 2, 0x40, 0x80, 5, "hello", 5, "world" -> 0x20, 0x20, 2, 0x40, 0x80, 5, "hello", 5, "world"
// gas irOptimized: 93275
// gas legacy: 96214
// gas legacyOptimized: 93775
// test3(bytes[1][]): 0x20, 2, 0x40, 0xa0, 0x20, 5, "hello", 0x20, 5, "world" -> 0x20, 2, 0x40, 0xa0, 0x20, 5, "hello", 0x20, 5, "world"
// gas irOptimized: 93505
// gas legacy: 97500
// gas legacyOptimized: 94464
