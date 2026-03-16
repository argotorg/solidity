// Data section name containing a quote must be escaped in serialization
// to prevent a reparse failure during optimization (exercises Data::toString).
object "a" {
    code { {} }
    data "my\"data" hex"deadbeef"
}
// ====
// EVMVersion: >=cancun
// optimizationPreset: full
// outputs: Assembly
// ----
// Assembly:
//     /* "source":22:29   */
//   stop
// stop
// data_d4fd4e189132273036449fc9e11198c739161b4c0116a9a2dccdfa1c492006f1 deadbeef
