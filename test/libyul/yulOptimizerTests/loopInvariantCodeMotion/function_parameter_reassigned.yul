{
    function f(x) {
        x := add(x, 1)
        for { let a := 1 } iszero(eq(a, 10)) { a := add(a, 1) } {
            let not_inv := add(x, 42)
            a := add(a, 1)
            mstore(a, not_inv)
        }
    }
}
// ----
// step: loopInvariantCodeMotion
//
// {
//     function f(x)
//     {
//         x := add(x, 1)
//         let a := 1
//         for { } iszero(eq(a, 10)) { a := add(a, 1) }
//         {
//             let not_inv := add(x, 42)
//             a := add(a, 1)
//             mstore(a, not_inv)
//         }
//     }
// }
