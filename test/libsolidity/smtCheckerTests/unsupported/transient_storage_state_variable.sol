contract C {
    uint transient x;
    function test() public view { assert(x == 0); }
}
// ====
// EVMVersion: >=cancun
// SMTEngine: all
// ----
// UnimplementedFeatureError 1834: Transient storage variables are not supported.
