{
    function f(a, b) { }

    f(0, 0)
}
// ====
// stackOptimization: true
// EVMVersion: =current
// ----
//     /* "":32:39   */
//   tag_2
//     /* "":37:38   */
//   0x00
//     /* "":32:39   */
//   dup1
//   tag_1
//   jump	// in
// tag_2:
//     /* "":0:41   */
//   stop
//     /* "":6:26   */
// tag_1:
//   pop
//   pop
//   jump	// out
