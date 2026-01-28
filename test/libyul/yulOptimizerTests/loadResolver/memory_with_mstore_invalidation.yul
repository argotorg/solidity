{
    mstore(2, 10)
    mstore8(calldataload(0), 4)
    sstore(0, mload(2))
}
// ----
// step: loadResolver
//
// {
//     {
//         let _1 := 10
//         let _2 := 2
//         mstore(_2, _1)
//         let _3 := 4
//         let _4 := 0
//         mstore8(calldataload(_4), _3)
//         sstore(_4, mload(_2))
//     }
// }
