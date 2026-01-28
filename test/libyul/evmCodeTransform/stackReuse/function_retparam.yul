{
    function f() -> x, y { }

     let x, y := f()
}
// ====
// stackOptimization: true
// EVMVersion: =current
// ----
//     /* "":49:52   */
//   tag_2
//   tag_1
//   jump	// in
// tag_2:
//     /* "":0:54   */
//   stop
//     /* "":6:30   */
// tag_1:
//     /* "":25:26   */
//   0x00
//     /* "":22:23   */
//   0x00
//     /* "":6:30   */
//   swap2
//   jump	// out
