object "a" {
    code {
        let addr := linkersymbol("contract/test.sol:L")
        mstore(128, shl(227, 0x18530aaf))
        let success := extcall(addr, 0, 128, 4)
    }
}
// ====
// EVMVersion: >=shanghai
// bytecodeFormat: >=EOFv1
// ----
// Assembly:
//     /* "source":178:179   */
//   0x04
//     /* "source":173:176   */
//   0x80
//     /* "source":170:171   */
//   0x00
//     /* "source":58:93   */
//   linkerSymbol("f919ba91ac99f96129544b80b9516b27a80e376b9dc693819d0b18b7e0395612")
//     /* "source":127:137   */
//   0x18530aaf
//     /* "source":122:125   */
//   0xe3
//     /* "source":118:138   */
//   shl
//     /* "source":106:139   */
//   dup4
//   mstore
//     /* "source":156:180   */
//   extcall
//     /* "source":152:181   */
//   pop
//     /* "source":22:197   */
//   stop
// Bytecode: ef000101000402000100270400000000800006600460805f7300000000000000000000000000000000000000006318530aaf60e31b8352f85000
// Opcodes: 0xEF STOP ADD ADD STOP DIV MUL STOP ADD STOP 0x27 DIV STOP STOP STOP STOP DUP1 STOP MOD PUSH1 0x4 PUSH1 0x80 PUSH0 PUSH20 0x0 PUSH4 0x18530AAF PUSH1 0xE3 SHL DUP4 MSTORE EXTCALL POP STOP
// SourceMappings: 178:1:0:-:0;173:3;170:1;58:35;127:10;122:3;118:20;106:33;;156:24;152:29;22:175
