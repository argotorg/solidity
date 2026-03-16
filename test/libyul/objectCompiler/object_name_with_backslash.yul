// Object name containing a backslash must be escaped in serialization
// to prevent a reparse failure during optimization.
object "foo\\bar" {
    code { {} }
}
// ====
// EVMVersion: >=cancun
// optimizationPreset: full
// outputs: Assembly
// ----
// Assembly:
//     /* "source":29:36   */
//   stop
