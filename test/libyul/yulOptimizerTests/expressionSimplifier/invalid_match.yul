// regression test for https://github.com/argotorg/solidity/issues/16155
{
    function identity(value) -> ret { ret := value }

    function f() -> ret
    {
        let id1 := identity(0x01)
        let x := 0x05
        {
            let const_six := 0x06
            let id2 := identity(0x01)
            x := or(0x06, id2)
        }
        // check that we don't substitute `or(const_six, id2)` for `x`
        ret := or(id1, x)
    }

    mstore(42, f())
}
// ----
// step: expressionSimplifier
//
// {
//     { mstore(42, f()) }
//     function identity(value) -> ret
//     { ret := value }
//     function f() -> ret_1
//     {
//         let id1 := identity(0x01)
//         let x := 0x05
//         { x := or(0x06, id1) }
//         ret_1 := or(id1, x)
//     }
// }
