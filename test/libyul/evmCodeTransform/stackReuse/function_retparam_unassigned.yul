{
    function f() -> x { pop(callvalue()) }

    pop(f())
}
// ====
// stackOptimization: true
// EVMVersion: =current
// ----
//     /* "":54:57   */
//   tag_2
//   tag_1
//   jump	// in
// tag_2:
//     /* "":50:58   */
//   pop
//     /* "":0:60   */
//   stop
//     /* "":6:44   */
// tag_1:
//     /* "":22:23   */
//   0x00
//     /* "":6:44   */
//   swap1
//     /* "":30:41   */
//   callvalue
//     /* "":26:42   */
//   pop
//     /* "":6:44   */
//   jump	// out
