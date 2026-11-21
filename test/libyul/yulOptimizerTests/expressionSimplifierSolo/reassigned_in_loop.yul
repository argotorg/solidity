{
    let x := 7
    let y := 3
    for {} lt(x, 100) { x := add(x, 1) } {
        // `x` changes in the loop, `y` does not.
        sstore(add(x, 3), add(y, 3))
    }
}
// ----
// step: expressionSimplifierSolo
//
// {
//     let x := 7
//     let y := 3
//     for { } lt(x, 100) { x := add(x, 1) }
//     { sstore(add(x, 3), 6) }
// }
