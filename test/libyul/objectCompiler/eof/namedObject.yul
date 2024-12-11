object "a" {
  code {}
}
// ====
// EVMVersion: >=constantinople
// bytecodeFormat: >=EOFv1
// ----
// Assembly:
//     /* "source":22:29   */
//   stop
// Bytecode: ef00010100040200010001040000000080000000
// Opcodes: 0xEF STOP ADD ADD STOP DIV MUL STOP ADD STOP ADD DIV STOP STOP STOP STOP DUP1 STOP STOP STOP
// SourceMappings: 22:7:0:-:0
