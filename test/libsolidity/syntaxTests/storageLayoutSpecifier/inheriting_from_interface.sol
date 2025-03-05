interface I { }

contract C layout at 42 is I { }
// ----
// UnimplementedFeatureError 1834: (17-49): Code generation is not supported for contracts with specified storage layout base.
