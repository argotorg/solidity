{
    let v := calldataload(0xff)
    switch calldataload(0)
    case 0 {
        v := add(v, 0x20)
    }
    let a1 := add(v, 0x20)
    let a := a1
    switch calldataload(0)
    case 0 {
        v := add(v, 0x20)
    }
    let y := 7
    mstore(v, y)
    sstore(0, mload(a))
}

// ----
// step: fullSuite
//
// {
//     {
//         let v := calldataload(0xff)
//         let _1 := iszero(calldataload(0))
//         if _1 { v := add(v, 0x20) }
//         let a1 := add(v, 0x20)
//         if _1 { v := a1 }
//         mstore(v, 7)
//         sstore(0, mload(a1))
//     }
// }
