{
    function f() -> x { pop(address()) for { pop(callvalue()) } 0 {} { } }

    pop(f())
}
// ====
// stackOptimization: true
// EVMVersion: =current
// ----
//     /* "":86:89   */
//   tag_2
//   tag_1
//   jump	// in
// tag_2:
//     /* "":82:90   */
//   pop
//     /* "":0:92   */
//   stop
//     /* "":6:76   */
// tag_1:
//     /* "":22:23   */
//   0x00
//     /* "":6:76   */
//   swap1
//     /* "":30:39   */
//   address
//     /* "":26:40   */
//   pop
//     /* "":51:62   */
//   callvalue
//     /* "":47:63   */
//   pop
//     /* "":6:76   */
//   jump	// out
