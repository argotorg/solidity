contract A layout at (2**256 + 1) * 2  - 2**256 - 3 {}
contract B layout at (2**2 - 2**3) * (2**5 - 2**8) {}
// ----
// UnimplementedFeatureError 1834: (0-54): Code generation is not supported for contracts with specified storage layout base.
