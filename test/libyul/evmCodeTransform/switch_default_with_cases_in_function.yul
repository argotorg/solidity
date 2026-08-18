{
    function dispatch(fun, x) -> y {
        switch fun
        case 0 { y := implA(x) }
        case 1 { y := implB(x) }
        default { revertPanic() }
    }
    function implA(x) -> r { r := add(x, 1) }
    function implB(x) -> r { r := add(x, 2) }
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
//     /* "":453:475   */
//   tag_6
//     /* "":472:473   */
//   0x00
//     /* "":459:474   */
//   calldataload
//     /* "":453:475   */
//   tag_5
//   jump	// in
// tag_6:
//     /* "":450:451   */
//   0x00
//     /* "":443:476   */
//   sstore
//     /* "":0:478   */
//   stop
//     /* "":6:163   */
// tag_1:
//     /* "":66:90   */
//   dup1
//     /* "":71:72   */
//   0x00
//     /* "":66:90   */
//   eq
//   tag_7
//   jumpi
//     /* "":47:157   */
// tag_8:
//     /* "":104:105   */
//   0x01
//     /* "":99:123   */
//   eq
//   tag_9
//   jumpi
//     /* "":47:157   */
// tag_10:
//     /* "":142:155   */
//   tag_4
//   jump	// in
//     /* "":106:123   */
// tag_9:
//     /* "":113:121   */
//   tag_11
//   swap1
//   tag_3
//   jump	// in
// tag_11:
//     /* "":106:123   */
//   swap1
//     /* "":47:157   */
// tag_12:
//     /* "":6:163   */
//   jump	// out
//     /* "":73:90   */
// tag_7:
//     /* "":80:88   */
//   pop
//   tag_13
//   swap1
//   tag_2
//   jump	// in
// tag_13:
//     /* "":73:90   */
//   swap1
//   jump(tag_12)
//     /* "":168:209   */
// tag_2:
//     /* "":205:206   */
//   0x01
//     /* "":168:209   */
//   swap1
//     /* "":198:207   */
//   add
//     /* "":168:209   */
//   swap1
//   jump	// out
//     /* "":214:255   */
// tag_3:
//     /* "":251:252   */
//   0x02
//     /* "":214:255   */
//   swap1
//     /* "":244:253   */
//   add
//     /* "":214:255   */
//   swap1
//   jump	// out
//     /* "":260:338   */
// tag_4:
//     /* "":303:307   */
//   0x51
//     /* "":300:301   */
//   0x00
//     /* "":293:308   */
//   mstore
//     /* "":327:331   */
//   0x20
//     /* "":324:325   */
//   0x00
//     /* "":317:332   */
//   revert
//     /* "":343:438   */
// tag_5:
//     /* "":398:399   */
//   0x02
//     /* "":384:400   */
//   tag_14
//     /* "":343:438   */
//   swap2
//     /* "":384:400   */
//   tag_1
//   jump	// in
// tag_14:
//     /* "":380:401   */
//   pop
//     /* "":417:418   */
//   0x07
//     /* "":427:432   */
//   swap1
//   jump	// out
