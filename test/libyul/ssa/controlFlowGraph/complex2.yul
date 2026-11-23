{
    function f(a, b) -> c {
        for { let x := 42 } lt(x, a) {
            x := add(x, 1)
            if calldataload(x)
            {
                sstore(0, x)
                leave
                sstore(0x01, 0x0101)
            }
            sstore(0xFF, 0xFFFF)
        }
        {
            switch mload(x)
            case 0 {
                sstore(0x02, 0x0202)
                break
                sstore(0x03, 0x0303)
            }
            case 1 {
                sstore(0x04, 0x0404)
                leave
                sstore(0x05, 0x0505)
            }
            case 2 {
                sstore(0x06, 0x0606)
                revert(0, 0)
                sstore(0x07, 0x0707)
            }
            case 3 {
                sstore(0x08, 0x0808)
            }
            default {
                if mload(b) {
                    return(0, 0)
                    sstore(0x09, 0x0909)
                }
                    sstore(0x0A, 0x0A0A)
            }
            sstore(0x0B, 0x0B0B)
        }
        sstore(0x0C, 0x0C0C)
        c:=27
    }
    sstore(0x1,0x1)
    pop(f(1,2))
    let z:= add(5,sload(0))
    let w := f(z,sload(4))
    sstore(z,w)
    let x := f(w,sload(5))
    sstore(0x1,x)
}
// ----
// #0:
//     ; dfs 0..0
//     ; live-in:
//     ; live-out:
//     ; used:
//     v0 = const 0x01
//     builtin @sstore v0, v0
//     v2 = const 0x02
//     v3 = call @f v0, v2
//     builtin @pop v3
//     v5 = const 0x00
//     v6 = builtin @sload v5
//     v7 = const 0x05
//     v8 = builtin @add v7, v6
//     v9 = const 0x04
//     v10 = builtin @sload v9
//     v11 = call @f v8, v10
//     builtin @sstore v8, v11
//     v13 = builtin @sload v7
//     v14 = call @f v11, v13
//     builtin @sstore v0, v14
//     main_exit
//
// func @f(args: (v0, v1)) -> 1 {
// #0:
//     ; dfs 0..16
//     ; live-in: v1[1], v0[1]
//     ; live-out: v1[1], v0[1]
//     ; used:
//     v0 = arg 0
//     v1 = arg 1
//     v2 = const 0x00
//     v3 = const 0x2a
//     v9 = const 0x0202
//     v10 = const 0x02
//     v12 = const 0x0303
//     v13 = const 0x03
//     v15 = const 0x01
//     v17 = const 0x0404
//     v18 = const 0x04
//     v21 = const 0x0505
//     v22 = const 0x05
//     v25 = const 0x0606
//     v26 = const 0x06
//     v30 = const 0x0707
//     v31 = const 0x07
//     v34 = const 0x0808
//     v35 = const 0x08
//     v41 = const 0x0909
//     v42 = const 0x09
//     v44 = const 0x0a0a
//     v45 = const 0x0a
//     v47 = const 0x0b0b
//     v48 = const 0x0b
//     v79 = const 0x0101
//     v81 = const 0xffff
//     v82 = const 0xff
//     upsilon v3 -> ^v5
//     v134 = const 0x0c0c
//     v135 = const 0x0c
//     v137 = const 0x1b
//     jump #1
// #1: preds: #0, #21
//     ; back edge from: #21
//     ; dfs 1..16
//     ; live-in: phi5[4], v1[1], v0[1]
//     ; live-out: phi5[2], v1[1], v0[1]
//     ; used: phi5[2]
//     v5 = phi
//     v6 = builtin @lt v5, v0
//     branch v6, #2, #4
// #2: preds: #1
//     ; dfs 2..16
//     ; live-in: phi5[2], v1[1], v0[1]
//     ; live-out: phi5[1], v1[1], v7[3], v0[1]
//     ; used: phi5[1]
//     v7 = builtin @mload v5
//     v8 = builtin @eq v7, v2
//     branch v8, #6, #7
// #4: preds: #1, #6
//     ; dfs 4..4
//     ; live-in:
//     ; live-out:
//     ; used:
//     builtin @sstore v135, v134
//     return v137
// #5: preds: #15, #18
//     ; dfs 11..13
//     ; live-in: phi5[1], v1[1], v0[1]
//     ; live-out: v63[1], v1[1], v0[1]
//     ; used: phi5[1]
//     builtin @sstore v48, v47
//     v63 = builtin @add v5, v15
//     v64 = builtin @calldataload v63
//     branch v64, #20, #21
// #6: preds: #2
//     ; dfs 3..4
//     ; live-in:
//     ; live-out:
//     ; used:
//     builtin @sstore v10, v9
//     jump #4
// #7: preds: #2
//     ; dfs 5..16
//     ; live-in: phi5[1], v1[1], v7[3], v0[1]
//     ; live-out: phi5[1], v1[1], v7[2], v0[1]
//     ; used: v7[1]
//     v16 = builtin @eq v7, v15
//     branch v16, #9, #10
// #9: preds: #7
//     ; dfs 6..6
//     ; live-in:
//     ; live-out:
//     ; used:
//     builtin @sstore v18, v17
//     return v2
// #10: preds: #7
//     ; dfs 7..16
//     ; live-in: phi5[1], v1[1], v7[2], v0[1]
//     ; live-out: phi5[1], v1[1], v7[1], v0[1]
//     ; used: v7[1]
//     v24 = builtin @eq v7, v10
//     branch v24, #12, #13
// #12: preds: #10
//     ; dfs 8..8
//     ; live-in:
//     ; live-out:
//     ; used:
//     builtin @sstore v26, v25
//     builtin @revert v2, v2
//     terminated
// #13: preds: #10
//     ; dfs 9..16
//     ; live-in: phi5[1], v1[1], v7[1], v0[1]
//     ; live-out: phi5[1], v1[1], v0[1]
//     ; used: v7[1]
//     v33 = builtin @eq v7, v13
//     branch v33, #15, #16
// #15: preds: #13
//     ; dfs 10..13
//     ; live-in: phi5[1], v1[1], v0[1]
//     ; live-out: phi5[1], v1[1], v0[1]
//     ; used:
//     builtin @sstore v35, v34
//     jump #5
// #16: preds: #13
//     ; dfs 14..16
//     ; live-in: phi5[1], v1[1], v0[1]
//     ; live-out: phi5[1], v1[1], v0[1]
//     ; used:
//     v38 = builtin @mload v1
//     branch v38, #17, #18
// #17: preds: #16
//     ; dfs 15..15
//     ; live-in:
//     ; live-out:
//     ; used:
//     builtin @return v2, v2
//     terminated
// #18: preds: #16
//     ; dfs 16..16
//     ; live-in: phi5[1], v1[1], v0[1]
//     ; live-out: phi5[1], v1[1], v0[1]
//     ; used:
//     builtin @sstore v45, v44
//     jump #5
// #20: preds: #5
//     ; dfs 12..12
//     ; live-in: v63[1]
//     ; live-out:
//     ; used: v63[1]
//     builtin @sstore v2, v63
//     return v2
// #21: preds: #5
//     ; dfs 13..13
//     ; live-in: v63[1], v1[1], v0[1]
//     ; live-out: v63[1], v1[1], v0[1]
//     ; used:
//     builtin @sstore v82, v81
//     upsilon v63 -> ^v5
//     jump #1
// }
//
