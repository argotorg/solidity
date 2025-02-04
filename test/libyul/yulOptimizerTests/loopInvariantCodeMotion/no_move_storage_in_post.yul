{
    let b := 1
    // invalidates storage in post
    for { let a := 1 } iszero(eq(a, 10)) { sstore(0x00, 0x01)} {
        let inv := add(b, 42)
        let x := sload(mul(inv, 3))
        a := add(x, 1)
        mstore(a, inv)
    }
}
// ----
// step: loopInvariantCodeMotion
//
// {
//     let b := 1
//     let a := 1
//     let inv := add(b, 42)
//     for { } iszero(eq(a, 10)) { sstore(0x00, 0x01) }
//     {
//         let x := sload(mul(inv, 3))
//         a := add(x, 1)
//         mstore(a, inv)
//     }
// }
