contract A { }
contract B { }
contract C is A, B layout at 0x1234 { }
contract D layout at 0xABCD is A, B { }
// ----
// UnimplementedFeatureError 1834: (30-69): Code generation is not supported for contracts with specified storage layout base.
