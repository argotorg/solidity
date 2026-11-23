{
    let s
    for {let i := 0} lt(i, 10) {i := add(i, 1)} {
        for {let j := 0} lt(j, 10) {j := add(j, 1)} {
            s := add(s, mul(i, j))
        }
    }
    mstore(0, s)
}
// ----
// object "object"
//     ; spilled: {}
// #0:
//     ; in: []
//     v0 = const 0x00
//     v1 = const 0x0a
//     v10 = const 0x01
//     upsilon v0 -> ^v2
//     upsilon v0 -> ^v16
//     ; out: []
//     jump #1
// #1: preds: #0, #8
//     ; in: [phi2, phi16]
//     v2 = phi
//     ; [phi2, phi16, lit1, phi2]
//     v3 = builtin @lt v2, v1
//     v16 = phi
//     ; out: [phi2, phi16, v3]
//     branch v3, #2, #4
// #2: preds: #1
//     ; in: [phi2, phi16]
//     upsilon v0 -> ^v4
//     upsilon v16 -> ^v8
//     ; out: [phi2, phi16]
//     jump #5
// #4: preds: #1
//     ; in: [JUNK, phi16]
//     ; [JUNK, phi16, lit0]
//     builtin @mstore v0, v16
//     ; out: [JUNK]
//     main_exit
// #5: preds: #2, #6
//     ; in: [phi2, phi8, phi4]
//     v4 = phi
//     ; [phi2, phi8, phi4, lit1, phi4]
//     v5 = builtin @lt v4, v1
//     v8 = phi
//     ; out: [phi2, phi8, phi4, v5]
//     branch v5, #6, #8
// #6: preds: #5
//     ; in: [phi2, phi8, phi4]
//     ; [phi2, phi8, phi4, phi4, phi2]
//     v7 = builtin @mul v2, v4
//     ; [phi2, phi4, v7, phi8]
//     v9 = builtin @add v8, v7
//     ; [phi2, v9, lit10, phi4]
//     v11 = builtin @add v4, v10
//     upsilon v11 -> ^v4
//     upsilon v9 -> ^v8
//     ; out: [phi2, v9, v11]
//     jump #5
// #8: preds: #5
//     ; in: [phi2, phi8, JUNK]
//     ; [phi2, phi8, lit10, phi2]
//     v19 = builtin @add v2, v10
//     upsilon v19 -> ^v2
//     upsilon v8 -> ^v16
//     ; out: [phi2, phi8, v19]
//     jump #1
//
