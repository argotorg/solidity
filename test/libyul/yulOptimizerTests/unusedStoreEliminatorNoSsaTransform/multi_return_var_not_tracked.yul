{
    function g() -> r1, r2
    {
        r1 := calldataload(0)
        r2 := calldataload(32)
    }
    let a, b := g()
    let c := add(a, 32)
    mstore(c, 0xAA)
    return(a, b)
}
// ----
// step: unusedStoreEliminatorNoSsaTransform
//
// {
//     function g() -> r1, r2
//     {
//         r1 := calldataload(0)
//         r2 := calldataload(32)
//     }
//     let a, b := g()
//     let c := add(a, 32)
//     mstore(c, 0xAA)
//     return(a, b)
// }
