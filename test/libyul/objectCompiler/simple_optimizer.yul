{
  let x := calldataload(0)
  let y := calldataload(0)
  let z := sub(y, x)
  sstore(add(x, 0), z)
}
// ====
// EVMVersion: >=shanghai
// optimizationPreset: full
// outputs: Assembly
// ----
// Assembly:
//     /* "source":63:64   */
//   0x00
//     /* "source":46:61   */
//   dup1
//   calldataload
//     /* "source":39:65   */
//   sstore
//     /* "source":27:73   */
//   stop
