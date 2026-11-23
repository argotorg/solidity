{
    let x
    for {let i := 0} x {i := add(i, 1)} {
        if mload(i) {
            x := add(x, i)
            x := add(x, mload(32))
        }
    }
    mstore(x, 33)
}
// ----
// object "object"
//     ; spilled: {}
// #0:
//     ; in: []
//     v0 = const 0x00
//     v5 = const 0x20
//     v8 = const 0x01
//     upsilon v0 -> ^v1
//     upsilon v0 -> ^v2
//     v20 = const 0x21
//     ; out: []
//     jump #1
// #1: preds: #0, #6
//     ; in: [phi1, phi2]
//     v1 = phi
//     v2 = phi
//     ; out: [phi1, phi2, phi1]
//     branch v1, #2, #4
// #2: preds: #1
//     ; in: [phi1, phi2]
//     ; [phi1, phi2, phi2]
//     v3 = builtin @mload v2
//     ; out: [phi1, phi2, v3]
//     branch v3, #5, #3
// #3: preds: #2
//     ; in: [phi1, phi2]
//     upsilon v1 -> ^v14
//     ; out: [phi1, phi2]
//     jump #6
// #4: preds: #1
//     ; in: [phi1, JUNK]
//     ; [phi1, lit20, phi1]
//     builtin @mstore v1, v20
//     ; out: [phi1]
//     main_exit
// #5: preds: #2
//     ; in: [phi1, phi2]
//     ; [phi2, phi2, phi1]
//     v4 = builtin @add v1, v2
//     ; [phi2, v4, lit5]
//     v6 = builtin @mload v5
//     ; [phi2, v6, v4]
//     v7 = builtin @add v4, v6
//     upsilon v7 -> ^v14
//     ; out: [phi2, v7]
//     jump #6
// #6: preds: #3, #5
//     ; in: [phi2, phi14]
//     v14 = phi
//     ; [phi14, lit8, phi2]
//     v12 = builtin @add v2, v8
//     upsilon v14 -> ^v1
//     upsilon v12 -> ^v2
//     ; out: [phi14, v12]
//     jump #1
//
