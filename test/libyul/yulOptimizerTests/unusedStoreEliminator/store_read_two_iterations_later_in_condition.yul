{
    let x := 1000
    // mstore(x, 7) in iteration k is read in the condition before iteration k + 2,
    // so it must not be removed.
    for { } mload(add(x, 64)) { mstore(x, 7) } {
        x := sub(x, 64)
    }
}
// ----
// step: unusedStoreEliminator
//
// {
//     {
//         let x := 1000
//         let x_3 := x
//         for { }
//         mload(add(x, 64))
//         {
//             let x_6 := x
//             mstore(x_6, 7)
//         }
//         {
//             let x_5 := x
//             x := sub(x_5, 64)
//             let x_4 := x
//         }
//     }
// }
