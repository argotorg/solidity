contract C layout at 0x1234 {
    uint layout;
    function at() public pure { }
}
// ----
// UnimplementedFeatureError 1834: (0-82): Code generation is not supported for contracts with specified storage layout base.
