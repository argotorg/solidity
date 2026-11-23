{
    for { let i := 0 } lt(i, 3) { i := add(i, 1) } {
        for { let j := 0 } lt(j, 3) { j := add(j, 1) } {
            for { let k := 0 } lt(k, 3) { k := add(k, 1) } {
                if mload(0) {
                    for { let l := 0 } lt(l, 3) { l := add(l, 1) } {
                        sstore(l, add(add(i,j),k))
                    }
                }
                if mload(1) {
                    for { let l := 0 } lt(l, 3) { l := add(l, 1) } {
                        sstore(l, add(add(i,j),k))
                    }
                }
            }
        }
    }
}

// ----
// #0:
//     ; dfs 0..19
//     ; live-in:
//     ; live-out:
//     ; used:
//     v0 = const 0x00
//     v1 = const 0x03
//     v17 = const 0x01
//     upsilon v0 -> ^v2
//     jump #1
// #1: preds: #0, #8
//     ; back edge from: #8
//     ; dfs 1..19
//     ; live-in: phi2[3]
//     ; live-out: phi2[1]
//     ; used: phi2[2]
//     v2 = phi
//     v3 = builtin @lt v2, v1
//     branch v3, #2, #4
// #2: preds: #1
//     ; dfs 2..18
//     ; live-in: phi2[1]
//     ; live-out: phi2[1]
//     ; used:
//     upsilon v0 -> ^v4
//     jump #5
// #4: preds: #1
//     ; dfs 19..19
//     ; live-in:
//     ; live-out:
//     ; used:
//     main_exit
// #5: preds: #2, #12
//     ; back edge from: #12
//     ; dfs 3..18
//     ; live-in: phi2[1], phi4[3]
//     ; live-out: phi2[1], phi4[1]
//     ; used: phi4[2]
//     v4 = phi
//     v5 = builtin @lt v4, v1
//     branch v5, #6, #8
// #6: preds: #5
//     ; dfs 4..17
//     ; live-in: phi2[1], phi4[1]
//     ; live-out: phi2[1], phi4[1]
//     ; used:
//     upsilon v0 -> ^v6
//     jump #9
// #8: preds: #5
//     ; dfs 18..18
//     ; live-in: phi2[1]
//     ; live-out: v78[1]
//     ; used: phi2[1]
//     v78 = builtin @add v2, v17
//     upsilon v78 -> ^v2
//     jump #1
// #9: preds: #6, #20
//     ; back edge from: #20
//     ; dfs 5..17
//     ; live-in: phi6[3], phi2[1], phi4[1]
//     ; live-out: phi6[1], phi2[1], phi4[1]
//     ; used: phi6[2]
//     v6 = phi
//     v7 = builtin @lt v6, v1
//     branch v7, #10, #12
// #10: preds: #9
//     ; dfs 6..16
//     ; live-in: phi6[1], phi2[1], phi4[1]
//     ; live-out: phi6[1], phi2[1], phi4[1]
//     ; used:
//     v8 = builtin @mload v0
//     branch v8, #13, #14
// #12: preds: #9
//     ; dfs 17..17
//     ; live-in: phi4[1], phi2[1]
//     ; live-out: v73[1], phi2[1]
//     ; used: phi4[1]
//     v73 = builtin @add v4, v17
//     upsilon v73 -> ^v4
//     jump #5
// #13: preds: #10
//     ; dfs 7..16
//     ; live-in: phi6[1], phi2[1], phi4[1]
//     ; live-out: phi6[1], phi2[1], phi4[1]
//     ; used:
//     upsilon v0 -> ^v9
//     jump #15
// #14: preds: #10, #18
//     ; dfs 11..16
//     ; live-in: phi6[1], phi2[1], phi4[1]
//     ; live-out: phi6[1], phi2[1], phi4[1]
//     ; used:
//     v29 = builtin @mload v17
//     branch v29, #19, #20
// #15: preds: #13, #16
//     ; back edge from: #16
//     ; dfs 8..16
//     ; live-in: phi9[4], phi6[1], phi2[1], phi4[1]
//     ; live-out: phi9[2], phi6[1], phi2[1], phi4[1]
//     ; used: phi9[2]
//     v9 = phi
//     v10 = builtin @lt v9, v1
//     branch v10, #16, #18
// #16: preds: #15
//     ; dfs 9..9
//     ; live-in: phi9[2], phi6[1], phi2[1], phi4[1]
//     ; live-out: v18[1], phi6[1], phi2[1], phi4[1]
//     ; used: phi9[2]
//     v14 = builtin @add v2, v4
//     v15 = builtin @add v14, v6
//     builtin @sstore v9, v15
//     v18 = builtin @add v9, v17
//     upsilon v18 -> ^v9
//     jump #15
// #18: preds: #15
//     ; dfs 10..16
//     ; live-in: phi6[1], phi2[1], phi4[1]
//     ; live-out: phi6[1], phi2[1], phi4[1]
//     ; used:
//     jump #14
// #19: preds: #14
//     ; dfs 12..16
//     ; live-in: phi6[1], phi2[1], phi4[1]
//     ; live-out: phi6[1], phi2[1], phi4[1]
//     ; used:
//     upsilon v0 -> ^v30
//     jump #21
// #20: preds: #14, #24
//     ; dfs 16..16
//     ; live-in: phi6[1], phi2[1], phi4[1]
//     ; live-out: v59[1], phi2[1], phi4[1]
//     ; used: phi6[1]
//     v59 = builtin @add v6, v17
//     upsilon v59 -> ^v6
//     jump #9
// #21: preds: #19, #22
//     ; back edge from: #22
//     ; dfs 13..16
//     ; live-in: phi30[4], phi6[1], phi2[1], phi4[1]
//     ; live-out: phi30[2], phi6[1], phi2[1], phi4[1]
//     ; used: phi30[2]
//     v30 = phi
//     v31 = builtin @lt v30, v1
//     branch v31, #22, #24
// #22: preds: #21
//     ; dfs 14..14
//     ; live-in: phi30[2], phi6[1], phi2[1], phi4[1]
//     ; live-out: v38[1], phi6[1], phi2[1], phi4[1]
//     ; used: phi30[2]
//     v35 = builtin @add v2, v4
//     v36 = builtin @add v35, v6
//     builtin @sstore v30, v36
//     v38 = builtin @add v30, v17
//     upsilon v38 -> ^v30
//     jump #21
// #24: preds: #21
//     ; dfs 15..16
//     ; live-in: phi6[1], phi2[1], phi4[1]
//     ; live-out: phi6[1], phi2[1], phi4[1]
//     ; used:
//     jump #20
//
