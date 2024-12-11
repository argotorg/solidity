object "a" {
  code { sstore(0, 1) }
}
// ====
// EVMVersion: >=shanghai
// bytecodeFormat: >=EOFv1
// ----
// Assembly:
//     /* "source":36:37   */
//   0x01
//     /* "source":33:34   */
//   0x00
//     /* "source":26:38   */
//   sstore
//     /* "source":22:42   */
//   stop
// Bytecode: ef00010100040200010005040000000080000260015f5500
// Opcodes: 0xEF STOP ADD ADD STOP DIV MUL STOP ADD STOP SDIV DIV STOP STOP STOP STOP DUP1 STOP MUL PUSH1 0x1 PUSH0 SSTORE STOP
// SourceMappings: 36:1:0:-:0;33;26:12;22:20
