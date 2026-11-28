{
    let a := 0
    {
        let t := calldataload(0)
        a := add(t, 2)
        sstore(add(a, 3), 1)
    }
    // `a` is still known as `add(t, 2)`, but `t` is out of scope.
    sstore(add(a, 3), 2)
}
// ----
// step: expressionSimplifierSolo
//
// {
//     let a := 0
//     {
//         let t := calldataload(0)
//         a := add(t, 2)
//         sstore(add(t, 5), 1)
//     }
//     sstore(add(a, 3), 2)
// }
