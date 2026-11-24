{
    let v := 32
    if true {
        if and(calldataload(0), 1) {
            v := 32
        }
    }
    let a1 := v
    let a := a1
    if true {
        v := 0
        if and(calldataload(0), 1) {
            v := 32
        }
    }
    let b := add(v, 32)
    let newValue := 7
    mstore(b, newValue)
    let result := mload(a)
    sstore(0x8, result)
}

// ----
// step: fullSuite
//
// {
//     {
//         let v := 32
//         let _1 := and(calldataload(0), 1)
//         if _1 { v := v }
//         let a := v
//         v := 0
//         if _1 { v := 32 }
//         mstore(add(v, 32), 7)
//         sstore(0x8, mload(a))
//     }
// }
