object "a" {
  code {
    let x := calldataload(0)
    let y := calldataload(0)
    let z := sub(y, x)
    sstore(add(x, 0), z)
  }
  object "sub" {
    code {
      let x := calldataload(0)
      let y := calldataload(0)
      let z := sub(y, x)
      sstore(add(x, 0), z)
    }
  }
}
// ====
// EVMVersion: >=shanghai
// bytecodeFormat: >=EOFv1
// optimizationPreset: full
// ----
// Assembly:
//     /* "source":58:59   */
//   0x00
//     /* "source":41:56   */
//   dup1
//   calldataload
//     /* "source":34:60   */
//   sstore
//     /* "source":22:68   */
//   stop
// stop
//
// sub_0: assembly {
//         /* "source":141:142   */
//       0x00
//         /* "source":124:139   */
//       dup1
//       calldataload
//         /* "source":117:143   */
//       sstore
//         /* "source":101:155   */
//       stop
// }
// Bytecode: ef0001010004020001000504000000008000025f80355500
// Opcodes: 0xEF STOP ADD ADD STOP DIV MUL STOP ADD STOP SDIV DIV STOP STOP STOP STOP DUP1 STOP MUL PUSH0 DUP1 CALLDATALOAD SSTORE STOP
// SourceMappings: 58:1:0:-:0;41:15;;34:26;22:46
