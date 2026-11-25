// mstore(v, 0xAA) must NOT be eliminated: the next iteration reads it back through w,
// with the pointer carried across iterations through storage, not through a Yul variable.
{
    sstore(0, 64)
    for { let i := 0 } lt(i, 2) { i := add(i, 1) } {
        let v := sload(0)
        let w := add(v, 32)
        mstore(v, 0xAA)
        sstore(0, sub(v, 32))
        sstore(1, mload(w))
    }
}
// ----
// step: fullSuite
//
// {
//     {
//         sstore(0, 64)
//         let i := 0
//         for { } lt(i, 2) { i := add(i, 1) }
//         {
//             let v := sload(0)
//             mstore(v, 0xAA)
//             sstore(0, add(v, not(31)))
//             sstore(1, mload(add(v, 32)))
//         }
//     }
// }
