// Test that object names containing special characters (e.g. quotes) are correctly
// escaped in toString(), preventing a reparse failure during optimization.
object "3\"{code{}}e0003" {
    code { {} }
}
// ====
// EVMVersion: >=cancun
// optimizationPreset: full
// outputs: Assembly
// ----
// Assembly:
//     /* "source":37:44   */
//   stop
