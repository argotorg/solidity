contract C {
    ufixed32x8 y;
    function f() public {
        assembly {
            sstore(y.slot, 1)
        }
    }
}
// ----
// UnimplementedFeatureError 5016: (95-101): Fixed point types are not implemented.
