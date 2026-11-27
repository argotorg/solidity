{
    let x := calldataload(0)
    sstore(x, 1)
    x := add(x, 1)
    sstore(sub(x, 1), 2)
}
// Same input as unusedStoreEliminatorNoSsaTransform/ssa_input_relates_reassigned_variable.yul.
// The SSA transform introduces x_7 and x_8 for the old and the new value of x, which never change.
// So x_8 is known to be add(x_7, 1) and sub(x_8, 1) is known to be the location of the first sstore,
// which gets removed.
// ----
// step: unusedStoreEliminator
//
// {
//     {
//         let x := calldataload(0)
//         let x_7 := x
//         let _2 := 1
//         x := add(x_7, 1)
//         let x_8 := x
//         let _4 := 2
//         sstore(sub(x_8, 1), _4)
//     }
// }
