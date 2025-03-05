contract A {}
contract B is A layout at 64 {}
contract C is A layout at 42 {}
// ----
// UnimplementedFeatureError 1834: (14-45): Code generation is not supported for contracts with specified storage layout base.
