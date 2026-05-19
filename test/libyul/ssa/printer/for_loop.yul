{
    let sum := 0
    let i := 0
    for { } lt(i, calldataload(0)) { i := add(i, 1) } {
        sum := add(sum, i)
    }
    sstore(0, sum)
}
// ----
// #0:
//     v0 = const 0x00
//     v6 = const 0x01
//     upsilon v0 -> ^v2
//     upsilon v0 -> ^v4
//     jump #1
// #1: preds: #0, #3
//     v1 = builtin @calldataload v0
//     v2 = phi
//     v3 = builtin @lt v2, v1
//     v4 = phi
//     branch v3, #2, #4
// #2: preds: #1
//     v5 = builtin @add v4, v2
//     jump #3
// #3: preds: #2
//     v7 = builtin @add v2, v6
//     upsilon v7 -> ^v2
//     upsilon v5 -> ^v4
//     jump #1
// #4: preds: #1
//     builtin @sstore v0, v4
//     main_exit
//
