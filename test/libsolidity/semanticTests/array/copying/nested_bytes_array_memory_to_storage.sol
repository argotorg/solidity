pragma abicoder v2;

contract C {
    bytes[][] s;

    function f() external returns (uint256) {
        bytes[][] memory m = new bytes[][](2);
        m[0] = new bytes[](2);
        m[0][0] = "hello";
        m[0][1] = "world";
        m[1] = new bytes[](1);
        m[1][0] = "foo";
        s = m;

        assert(s.length == 2);
        assert(s[0].length == 2);
        assert(s[1].length == 1);
        assert(keccak256(s[0][0]) == keccak256("hello"));
        assert(keccak256(s[0][1]) == keccak256("world"));
        assert(keccak256(s[1][0]) == keccak256("foo"));

        return s.length;
    }
}
// ----
// f() -> 2
// gas irOptimized: 161279
// gas legacy: 162759
// gas legacyOptimized: 160288
