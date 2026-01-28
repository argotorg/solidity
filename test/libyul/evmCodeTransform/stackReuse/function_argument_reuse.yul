{
    function f(a, b, c) -> x { pop(address()) sstore(a, c) pop(callvalue()) x := b }
    pop(f(0, 0, 0))
}
// ====
// stackOptimization: true
// EVMVersion: =current
// ----
//     /* "":95:105   */
//   tag_2
//     /* "":103:104   */
//   0x00
//     /* "":95:105   */
//   dup1
//   dup1
//   tag_1
//   jump	// in
// tag_2:
//     /* "":91:106   */
//   pop
//     /* "":0:108   */
//   stop
//     /* "":6:86   */
// tag_1:
//   swap2
//   swap1
//   swap2
//     /* "":37:46   */
//   address
//     /* "":33:47   */
//   pop
//     /* "":48:60   */
//   sstore
//     /* "":65:76   */
//   callvalue
//     /* "":61:77   */
//   pop
//     /* "":6:86   */
//   swap1
//   jump	// out
