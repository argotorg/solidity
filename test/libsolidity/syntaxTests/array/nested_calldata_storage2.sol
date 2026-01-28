pragma abicoder               v2;

contract C {
  uint[][] tmp_i;
  function i(uint[][] calldata s) external { tmp_i = s; }
}

// ====
// compileViaYul: false
// ----
// UnimplementedFeatureError 1834: (35-125): Copying nested calldata dynamic arrays to storage is not implemented in the old code generator.
