{
    function reverter() -> a, b { revert(0, 0) }
    // the cfg should reflect that reverter has two output variables although it cannot continue
    let x, y := reverter()
    sstore(x, y)
}
// ----
// #0:
//     ; dfs 0..0
//     ; live-in:
//     ; live-out:
//     ; used:
//     v0 = call @reverter { nocontinue = true }
//     v1 = proj v0, 0
//     v2 = proj v0, 1
//     terminated
//
// func @reverter(args: ()) -> 2 nocontinue {
// #0:
//     ; dfs 0..0
//     ; live-in:
//     ; live-out:
//     ; used:
//     v0 = const 0x00
//     builtin @revert v0, v0
//     terminated
// }
//
