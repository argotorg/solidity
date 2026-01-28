// This does not reuse the parameters for the return parameters
// We do not expect parameters to be fully unused, so the stack
// layout for a function is still fixed, even though parameters
// can be reused.
{
    function f(a, b, c, d) -> x, y { }

    let x, y := f(0, 0, 0, 0)
}
// ====
// stackOptimization: true
// EVMVersion: =current
// ----
//     /* "":268:281   */
//   tag_2
//     /* "":279:280   */
//   0x00
//     /* "":268:281   */
//   dup1
//   dup1
//   dup1
//   tag_1
//   jump	// in
// tag_2:
//     /* "":210:283   */
//   stop
//     /* "":216:250   */
// tag_1:
//   pop
//   pop
//   pop
//   pop
//     /* "":245:246   */
//   0x00
//     /* "":242:243   */
//   0x00
//     /* "":216:250   */
//   swap2
//   jump	// out
