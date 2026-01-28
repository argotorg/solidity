{
    function f() -> x { pop(address()) leave pop(callvalue()) }

    pop(f())
}
// ====
// stackOptimization: true
// EVMVersion: =current
// ----
//     /* "":75:78   */
//   tag_2
//   tag_1
//   jump	// in
// tag_2:
//     /* "":71:79   */
//   pop
//     /* "":0:81   */
//   stop
//     /* "":6:65   */
// tag_1:
//     /* "":22:23   */
//   0x00
//     /* "":6:65   */
//   swap1
//     /* "":30:39   */
//   address
//     /* "":26:40   */
//   pop
//     /* "":41:46   */
//   jump	// out
