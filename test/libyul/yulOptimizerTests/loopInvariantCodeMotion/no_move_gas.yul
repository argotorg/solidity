{
    for { let a := 1 } iszero(eq(a, 10)) { a := add(a, 1) } {
        let c := gas()
    }
}
// ====
// bytecodeFormat: legacy
// ----
// step: loopInvariantCodeMotion
//
// {
//     let a := 1
//     for { } iszero(eq(a, 10)) { a := add(a, 1) }
//     { let c := gas() }
// }
