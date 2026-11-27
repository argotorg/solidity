{
    let x := 1000
    let i := 0
    // mstore(x, 7) in iteration k is read by mload in iteration k + 2,
    // so it must not be removed.
    for { } lt(i, 3) { mstore(x, 7) i := add(i, 1) } {
        sstore(i, mload(add(x, 64)))
        x := sub(x, 64)
    }
}
// ----
// step: unusedStoreEliminatorNoSsaTransform
//
// {
//     let x := 1000
//     let i := 0
//     for { }
//     lt(i, 3)
//     {
//         mstore(x, 7)
//         i := add(i, 1)
//     }
//     {
//         sstore(i, mload(add(x, 64)))
//         x := sub(x, 64)
//     }
// }
