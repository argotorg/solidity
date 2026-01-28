object "a" {
  code {}
  // Unreferenced data is not added to the assembled bytecode.
  // TODO: This is not implemented for EOF. Uncomment line below when implemented.
  // data "str" "Hello, World!"
  // Unreferenced object is not added to the assembled bytecode.
  object "sub" {
    code { sstore(0, 1) }
    object "subsub" {
      code { sstore(2, 3) }
      data "str" hex"123456"
    }
  }
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
//     stop
//
//     sub_0: assembly {
//             /* "source":140:141   */
//           0x03
//             /* "source":137:138   */
//           0x02
//             /* "source":130:142   */
//           sstore
//             /* "source":126:146   */
//           stop
//         stop
//         data_6adf031833174bbe4c85eafe59ddb54e6584648c2c962c6f94791ab49caa0ad4 123456
//     }
// }
// Bytecode: ef00010100040200010001040000000080000000
// Opcodes: 0xEF STOP ADD ADD STOP DIV MUL STOP ADD STOP ADD DIV STOP STOP STOP STOP DUP1 STOP STOP STOP
// SourceMappings: 22:7:0:-:0
