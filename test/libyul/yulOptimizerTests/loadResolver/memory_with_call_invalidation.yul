{
    mstore(2, 9)
    sstore(0, mload(2))
    pop(call(0, 0, 0, 0, 0, 0, 0))
    sstore(0, mload(2))
}
// ====
// bytecodeFormat: legacy
// ----
// step: loadResolver
//
// {
//     {
//         let _1 := 9
//         let _2 := 2
//         mstore(_2, _1)
//         let _3 := _1
//         let _4 := 0
//         sstore(_4, _3)
//         pop(call(_4, _4, _4, _4, _4, _4, _4))
//         sstore(_4, mload(_2))
//     }
// }
