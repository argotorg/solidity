{
    function dispatch(fun, x) -> y {
        switch fun
        default { revertPanic() }
    }
    function revertPanic() {
        mstore(0, 0x51)
        revert(0, 0x20)
    }
    function outer(fun) -> ret {
        pop(dispatch(fun, 2))
        ret := 7
        leave
    }
    sstore(0, outer(calldataload(0)))
}
// ====
// EVMVersion: =current
// stackOptimization: true
// ----
//     /* "":314:315   */
//   0x00
//     /* "":301:316   */
//   calldataload
//     /* "":295:317   */
//   tag_3
//   jump	// in
//     /* "":6:97   */
// tag_1:
//     /* "":76:89   */
//   pop
//   tag_2
//   jump	// in
//     /* "":102:180   */
// tag_2:
//     /* "":145:149   */
//   0x51
//     /* "":142:143   */
//   0x00
//     /* "":135:150   */
//   mstore
//     /* "":169:173   */
//   0x20
//     /* "":166:167   */
//   0x00
//     /* "":159:174   */
//   revert
//     /* "":185:280   */
// tag_3:
//     /* "":240:241   */
//   0x02
//     /* "":185:280   */
//   swap1
//     /* "":226:242   */
//   tag_1
//   jump	// in
