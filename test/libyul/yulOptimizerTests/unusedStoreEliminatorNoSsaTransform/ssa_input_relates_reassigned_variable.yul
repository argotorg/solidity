{
    let x := calldataload(0)
    sstore(x, 1)
    x := add(x, 1)
    sstore(sub(x, 1), 2)
}
// Same input as unusedStoreEliminator/ssa_input_relates_reassigned_variable.yul.
// Without the SSA transform, `x := add(x, 1)` references x itself, so the new value of x is unknown
// and the first sstore is kept. With the SSA transform it is removed.
// ----
// step: unusedStoreEliminatorNoSsaTransform
//
// {
//     let x := calldataload(0)
//     sstore(x, 1)
//     x := add(x, 1)
//     sstore(sub(x, 1), 2)
// }
