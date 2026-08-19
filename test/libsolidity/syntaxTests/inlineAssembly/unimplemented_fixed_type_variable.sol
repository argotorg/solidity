contract C {
    function f() public pure returns (fixed x) {
        assembly {
            x := 1
        }
    }
}
// ----
// UnimplementedFeatureError 5016: (93-94): Fixed point types are not implemented.
