object "a" {
  code {}
  // Unreferenced data is not added to the assembled bytecode.
  data "str" "Hello, World!"
  object "sub" {
    code { sstore(0, 1) }
    object "subsub" {
      code { sstore(2, 3) }
      data "str" hex"123456"
    }
  }
}
// ====
// EVMVersion: >=constantinople
// bytecodeFormat: >=EOFv1
// ----
// Assembly:
//     /* "source":22:29   */
//   stop
// stop
// data_acaf3289d7b601cbd114fb36c4d29c85bbfd5e133f14cb355c3fd8d99367964f 48656c6c6f2c20576f726c6421
//
// sub_0: assembly {
//         /* "source":123:124   */
//       0x01
//         /* "source":120:121   */
//       0x00
//         /* "source":113:125   */
//       sstore
//         /* "source":109:129   */
//       stop
//     stop
//
//     sub_0: assembly {
//             /* "source":187:188   */
//           0x03
//             /* "source":184:185   */
//           0x02
//             /* "source":177:189   */
//           sstore
//             /* "source":173:193   */
//           stop
//         stop
//         data_6adf031833174bbe4c85eafe59ddb54e6584648c2c962c6f94791ab49caa0ad4 123456
//     }
// }
// Bytecode: ef0001010004020001000104000d00008000000048656c6c6f2c20576f726c6421
// Opcodes: 0xEF STOP ADD ADD STOP DIV MUL STOP ADD STOP ADD DIV STOP 0xD STOP STOP DUP1 STOP STOP STOP BASEFEE PUSH6 0x6C6C6F2C2057 PUSH16 0x726C6421000000000000000000000000
// SourceMappings: 22:7:0:-:0
