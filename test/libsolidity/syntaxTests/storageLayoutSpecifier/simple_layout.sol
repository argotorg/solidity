contract A layout at 0x1234 {}
contract B layout at 1024 {}
contract C layout at 0 {}
// ----
// UnimplementedFeatureError 1834: (0-30): Code generation is not supported for contracts with specified storage layout base.
