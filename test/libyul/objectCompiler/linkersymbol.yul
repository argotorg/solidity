object "a" {
    code {
        let addr := linkersymbol("contract/test.sol:L")
        mstore(128, shl(227, 0x18530aaf))
        sstore(0, balance(addr))
    }
}
// ====
// EVMVersion: >=shanghai
// outputs: Assembly
// ----
// Assembly:
//     /* "source":58:93   */
//   linkerSymbol("f919ba91ac99f96129544b80b9516b27a80e376b9dc693819d0b18b7e0395612")
//     /* "source":127:137   */
//   0x18530aaf
//     /* "source":122:125   */
//   0xe3
//     /* "source":118:138   */
//   shl
//     /* "source":113:116   */
//   0x80
//     /* "source":106:139   */
//   mstore
//     /* "source":162:175   */
//   balance
//     /* "source":159:160   */
//   0x00
//     /* "source":152:176   */
//   sstore
//     /* "source":22:192   */
//   stop
