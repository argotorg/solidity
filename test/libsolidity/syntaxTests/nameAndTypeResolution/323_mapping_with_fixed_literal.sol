contract test {
    mapping(ufixed8x1 => string) fixedString;
    function f() public {
        fixedString[0.5] = "Half";
    }
}
// ====
// compileViaYul: true
// ----
// UnimplementedFeatureError 1834: (96-112): Fixed point types not implemented.
