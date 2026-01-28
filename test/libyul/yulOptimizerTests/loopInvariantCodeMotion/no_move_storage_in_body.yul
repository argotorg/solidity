{
    let b := 1
    // invalidates storage in body
    for { let a := 1 } iszero(eq(a, 10)) { a := add(a, 1) } {
        let inv := add(b, 42)
        let x := sload(mul(inv, 3))
        a := add(x, 1)
        sstore(a, inv)
    }
}
// ----
// step: loopInvariantCodeMotion
//
// {
//     let b := 1
//     let a := 1
//     let inv := add(b, 42)
//     for { } iszero(eq(a, 10)) { a := add(a, 1) }
//     {
//         let x := sload(mul(inv, 3))
//         a := add(x, 1)
//         sstore(a, inv)
//     }
// }
