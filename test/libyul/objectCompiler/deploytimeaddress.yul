{
    let addr := deploytimeaddress()
    sstore(0, eq(addr, address()))
}
// ====
// EVMVersion: >=shanghai
// ----
// Assembly:
//     /* "source":63:82   */
//   deployTimeAddress()
//     /* "source":114:123   */
//   address
//     /* "source":105:124   */
//   eq
//     /* "source":102:103   */
//   0x00
//     /* "source":95:125   */
//   sstore
//     /* "source":27:141   */
//   stop
// Bytecode: 73000000000000000000000000000000000000000030145f5500
// Opcodes: PUSH20 0x0 ADDRESS EQ PUSH0 SSTORE STOP
// SourceMappings: 63:19:0:-:0;114:9;105:19;102:1;95:30;27:114
