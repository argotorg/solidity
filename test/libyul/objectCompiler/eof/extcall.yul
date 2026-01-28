object "a" {
    code {
        sstore(0, extcall(address(), 0, 0, 10))
        sstore(1, extdelegatecall(address(), 0, 0))
        sstore(2, extstaticcall(address(), 0, 0))
    }
}

// ====
// bytecodeFormat: >=EOFv1
// ----
// Assembly:
//     /* "source":81:83   */
//   0x0a
//     /* "source":78:79   */
//   0x00
//     /* "source":64:73   */
//   dup1
//   address
//     /* "source":56:84   */
//   extcall
//     /* "source":53:54   */
//   0x00
//     /* "source":46:85   */
//   sstore
//     /* "source":138:139   */
//   0x00
//     /* "source":124:133   */
//   dup1
//   address
//     /* "source":108:140   */
//   extdelegatecall
//     /* "source":105:106   */
//   0x01
//     /* "source":98:141   */
//   sstore
//     /* "source":192:193   */
//   0x00
//     /* "source":178:187   */
//   dup1
//   address
//     /* "source":164:194   */
//   extstaticcall
//     /* "source":161:162   */
//   0x02
//     /* "source":154:195   */
//   sstore
//     /* "source":22:211   */
//   stop
// Bytecode: ef000101000402000100170400000000800004600a5f8030f85f555f8030f96001555f8030fb60025500
// Opcodes: 0xEF STOP ADD ADD STOP DIV MUL STOP ADD STOP OR DIV STOP STOP STOP STOP DUP1 STOP DIV PUSH1 0xA PUSH0 DUP1 ADDRESS EXTCALL PUSH0 SSTORE PUSH0 DUP1 ADDRESS EXTDELEGATECALL PUSH1 0x1 SSTORE PUSH0 DUP1 ADDRESS EXTSTATICCALL PUSH1 0x2 SSTORE STOP
// SourceMappings: 81:2:0:-:0;78:1;64:9;;56:28;53:1;46:39;138:1;124:9;;108:32;105:1;98:43;192:1;178:9;;164:30;161:1;154:41;22:189
