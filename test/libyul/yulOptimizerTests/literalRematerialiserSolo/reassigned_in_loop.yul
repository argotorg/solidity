{
    let x := 7
    let y := 3
    for {} lt(x, 100) { x := add(x, 1) } {
        // `x` changes in the loop, `y` does not.
        sstore(x, y)
    }
    sstore(x, y)
}
// ----
// step: literalRematerialiserSolo
//
// {
//     let x := 7
//     let y := 3
//     for { } lt(x, 100) { x := add(x, 1) }
//     { sstore(x, 3) }
//     sstore(x, 3)
// }
