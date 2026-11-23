{
    let x
    if mload(42) {
        x := 5
    }
    sstore(x, x)
}
// ----
// #0:
//     ; dfs 0..3
//     ; live-in:
//     ; live-out:
//     ; used:
//     v0 = const 0x00
//     v1 = const 0x2a
//     v2 = builtin @mload v1
//     v3 = const 0x05
//     branch v2, #1, #3
// #1: preds: #0
//     ; dfs 1..2
//     ; live-in:
//     ; live-out:
//     ; used:
//     upsilon v3 -> ^v4
//     jump #2
// #2: preds: #3, #1
//     ; dfs 2..2
//     ; live-in: phi4[3]
//     ; live-out:
//     ; used: phi4[3]
//     v4 = phi
//     builtin @sstore v4, v4
//     main_exit
// #3: preds: #0
//     ; dfs 3..3
//     ; live-in:
//     ; live-out:
//     ; used:
//     upsilon v0 -> ^v4
//     jump #2
//
