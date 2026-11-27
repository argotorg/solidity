{
    let x := 1000
    // mstore(x, 7) in iteration k is read in the condition before iteration k + 5,
    // so it must not be removed.
    for { } mload(add(x, 256)) { mstore(x, 7) } {
        x := sub(x, 64)
    }
}
// ----
// step: unusedStoreEliminatorNoSsaTransform
//
// {
//     let x := 1000
//     for { } mload(add(x, 256)) { mstore(x, 7) }
//     { x := sub(x, 64) }
// }
