{
    function f() -> x, y, z { pop(callvalue()) }

    let x, y, z := f()
}
// ====
// stackOptimization: true
// EVMVersion: =current
// ----
//     /* "":71:74   */
//   tag_2
//   tag_1
//   jump	// in
// tag_2:
//     /* "":0:76   */
//   stop
//     /* "":6:50   */
// tag_1:
//     /* "":25:26   */
//   0x00
//     /* "":28:29   */
//   0x00
//     /* "":22:23   */
//   0x00
//     /* "":6:50   */
//   swap3
//     /* "":36:47   */
//   callvalue
//     /* "":32:48   */
//   pop
//     /* "":6:50   */
//   jump	// out
