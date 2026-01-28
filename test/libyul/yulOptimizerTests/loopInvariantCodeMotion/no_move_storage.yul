{
    let b := 1
    // invalidates state in body
    for { let a := 1 } iszero(eq(a, 10)) { a := add(a, 1) } {
        let inv := add(b, 42)
        pop(callcode(100, 0x010, 10, 0x00, 32, 0x0100, 32))
        let x := sload(mul(inv, 3))
        a := add(x, 1)
    }
}
// ====
// bytecodeFormat: legacy
// ----
// step: loopInvariantCodeMotion
//
// {
//     let b := 1
//     let a := 1
//     let inv := add(b, 42)
//     for { } iszero(eq(a, 10)) { a := add(a, 1) }
//     {
//         pop(callcode(100, 0x010, 10, 0x00, 32, 0x0100, 32))
//         let x := sload(mul(inv, 3))
//         a := add(x, 1)
//     }
// }
