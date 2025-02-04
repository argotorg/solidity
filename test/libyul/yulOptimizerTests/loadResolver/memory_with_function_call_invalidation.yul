{
    mstore(2, 10)
    g()
    sstore(0, mload(2))

    function g() {}
}
// ----
// step: loadResolver
//
// {
//     {
//         let _1 := 10
//         mstore(2, _1)
//         sstore(0, _1)
//     }
// }
