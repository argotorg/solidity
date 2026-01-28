{
  // This used to throw during stack layout generation.
  function g(b,s) -> y {
    y := g(b, g(y, s))
  }

  pop(g(0,0))
}
// ====
// stackOptimization: true
// EVMVersion: =current
// ----
//     /* "":121:122   */
//   0x00
//     /* "":117:123   */
//   dup1
//   tag_1
//   jump	// in
//     /* "":60:109   */
// tag_1:
//   pop
//     /* "":99:100   */
//   0x00
//     /* "":97:104   */
//   tag_1
//   jump	// in
