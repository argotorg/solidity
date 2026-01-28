{
    let b := 3
    function f(a, r) -> t {
        // r could be removed right away, but a cannot - this is not implemented, though
        let x := a a := 3 t := a
    }
    b := 7

    pop(f(0, 0))
}
// ====
// stackOptimization: true
// EVMVersion: =current
// ----
//     /* "":15:16   */
//   0x03
//     /* "":177:183   */
//   pop
//     /* "":182:183   */
//   0x07
//     /* "":193:200   */
//   pop
//   tag_2
//     /* "":198:199   */
//   0x00
//     /* "":193:200   */
//   dup1
//   tag_1
//   jump	// in
// tag_2:
//     /* "":189:201   */
//   pop
//     /* "":0:203   */
//   stop
//     /* "":21:172   */
// tag_1:
//   swap1
//   pop
//     /* "":153:159   */
//   pop
//     /* "":158:159   */
//   0x03
//     /* "":21:172   */
//   swap1
//   jump	// out
