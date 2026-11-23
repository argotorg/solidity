{
    function f(a, b) -> r {
        let x := add(a,b)
        r := sub(x,a)
    }
    function g() {
        sstore(0x01, 0x0101)
    }
    function h(x) {
        h(f(x, 0))
        g()
    }
    function i() -> v, w {
        v := 0x0202
        w := 0x0303
    }
    let x, y := i()
    h(x)
    h(y)
}
// ----
// #0:
//     ; dfs 0..0
//     ; live-in:
//     ; live-out:
//     ; used:
//     v0 = call @i
//     v1 = proj v0, 0
//     v2 = proj v0, 1
//     call @h v1 { nocontinue = true }
//     terminated
//
// func @f(args: (v0, v1)) -> 1 {
// #0:
//     ; dfs 0..0
//     ; live-in: v0[2], v1[1]
//     ; live-out: v4[1]
//     ; used: v0[2], v1[1]
//     v0 = arg 0
//     v1 = arg 1
//     v2 = const 0x00
//     v3 = builtin @add v0, v1
//     v4 = builtin @sub v3, v0
//     return v4
// }
//
// func @g(args: ()) -> 0 {
// #0:
//     ; dfs 0..0
//     ; live-in:
//     ; live-out:
//     ; used:
//     v0 = const 0x0101
//     v1 = const 0x01
//     builtin @sstore v1, v0
//     return
// }
//
// func @h(args: (v0)) -> 0 nocontinue {
// #0:
//     ; dfs 0..0
//     ; live-in: v0[1]
//     ; live-out:
//     ; used: v0[1]
//     v0 = arg 0
//     v1 = const 0x00
//     v2 = call @f v0, v1
//     call @h v2 { nocontinue = true }
//     terminated
// }
//
// func @i(args: ()) -> 2 {
// #0:
//     ; dfs 0..0
//     ; live-in:
//     ; live-out:
//     ; used:
//     v0 = const 0x00
//     v1 = const 0x0202
//     v2 = const 0x0303
//     return v1, v2
// }
//
