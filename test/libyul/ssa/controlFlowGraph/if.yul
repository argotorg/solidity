{
    let x := calldataload(3)
    if mload(42) {
        x := calldataload(77)
    }
    let y := calldataload(x)
    sstore(y, 0)
}
// ----
// #0:
//     ; dfs 0..3
//     ; live-in:
//     ; live-out: v1[1]
//     ; used:
//     v0 = const 0x03
//     v1 = builtin @calldataload v0
//     v2 = const 0x2a
//     v3 = builtin @mload v2
//     v4 = const 0x4d
//     v10 = const 0x00
//     branch v3, #1, #3
// #1: preds: #0
//     ; dfs 1..2
//     ; live-in:
//     ; live-out: v5[1]
//     ; used:
//     v5 = builtin @calldataload v4
//     upsilon v5 -> ^v6
//     jump #2
// #2: preds: #3, #1
//     ; dfs 2..2
//     ; live-in: phi6[2]
//     ; live-out:
//     ; used: phi6[2]
//     v6 = phi
//     v9 = builtin @calldataload v6
//     builtin @sstore v9, v10
//     main_exit
// #3: preds: #0
//     ; dfs 3..3
//     ; live-in: v1[1]
//     ; live-out: v1[1]
//     ; used:
//     upsilon v1 -> ^v6
//     jump #2
//
