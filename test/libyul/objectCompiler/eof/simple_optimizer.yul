{
  let x := calldataload(0)
  let y := calldataload(0)
  let z := sub(y, x)
  sstore(add(x, 0), z)
}
// ====
// EVMVersion: >=shanghai
// bytecodeFormat: >=EOFv1
// optimizationPreset: full
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
// Bytecode: ef0001010004020001000504000000008000025f80355500
// Opcodes: 0xEF STOP ADD ADD STOP DIV MUL STOP ADD STOP SDIV DIV STOP STOP STOP STOP DUP1 STOP MUL PUSH0 DUP1 CALLDATALOAD SSTORE STOP
// SourceMappings: 63:1:0:-:0;46:15;;39:26;27:46
