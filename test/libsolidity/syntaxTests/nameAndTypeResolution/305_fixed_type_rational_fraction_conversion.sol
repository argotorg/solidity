contract test {
    function f() public {
        fixed a = 4.5;
        ufixed d = 2.5;
        a; d;
    }
}
// ====
// compileViaYul: true
// ----
// Warning 2018: (20-108): Function state mutability can be restricted to pure
// UnimplementedFeatureError 1834: (50-63): Fixed point types not implemented.
