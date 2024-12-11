contract test {
    mapping(ufixed8x1 => string) fixedString;
    function f() public {
        fixedString[0.5] = "Half";
    }
}
// ====
// bytecodeFormat: legacy
// ----
// UnimplementedFeatureError 1834: (0-130): Not yet implemented - FixedPointType.
