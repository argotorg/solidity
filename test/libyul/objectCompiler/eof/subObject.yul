object "a" {
    code {}
    // Unreferenced data is not added to the assembled bytecode.
    // TODO: This is not implemented for EOF. Uncomment line below when implemented.
    // data "str" "Hello, World!"
    // Unreferenced object is not added to the assembled bytecode.
    object "sub" { code { sstore(0, 1) } }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// Assembly:
//     /* "source":22:29   */
//   stop
// stop
//
// sub_0: assembly {
//         /* "source":76:77   */
//       0x01
//         /* "source":73:74   */
//       0x00
//         /* "source":66:78   */
//       sstore
//         /* "source":62:82   */
//       stop
// }
// Bytecode: ef00010100040200010001040000000080000000
// Opcodes: 0xEF STOP ADD ADD STOP DIV MUL STOP ADD STOP ADD DIV STOP STOP STOP STOP DUP1 STOP STOP STOP
// SourceMappings: 22:7:0:-:0
