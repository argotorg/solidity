{
    let x := calldataload(0)
    if x {
        revert(0, 0)
    }
    let y := calldataload(32)
    if y {
        revert(0, 0)
    }
    sstore(x, y)
}
// ----
// object "object"
//     ; spilled: {}
// #0:
//     ; in: []
//     v0 = const 0x00
//     ; [lit0]
//     v1 = builtin @calldataload v0
//     v4 = const 0x20
//     ; out: [v1, v1]
//     branch v1, #1, #2
// #1: preds: #0
//     ; in: [JUNK]
//     ; [JUNK, lit0, lit0]
//     builtin @revert v0, v0
//     ; out: [JUNK]
//     terminated
// #2: preds: #0
//     ; in: [v1]
//     ; [v1, lit4]
//     v5 = builtin @calldataload v4
//     ; out: [v1, v5, v5]
//     branch v5, #4, #5
// #4: preds: #2
//     ; in: [JUNK, JUNK]
//     ; [JUNK, JUNK, lit0, lit0]
//     builtin @revert v0, v0
//     ; out: [JUNK, JUNK]
//     terminated
// #5: preds: #2
//     ; in: [v1, v5]
//     ; [v5, v1]
//     builtin @sstore v1, v5
//     ; out: []
//     main_exit
//
