abstract contract A { }

contract C layout at 42 is A { }
// ----
// UnimplementedFeatureError 1834: (25-57): Code generation is not supported for contracts with specified storage layout base.
