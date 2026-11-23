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
    // This call of g() is unreachable too as the one in h() but we wanna cover both cases.
    g()
}
// ----
// object "object"
//     ; spilled: {}
// #0:
//     ; in: []
//     ; [FunctionCallReturnLabel[0]]
//     v0 = call @i
//     v1 = proj v0, 0
//     v2 = proj v0, 1
//     ; [v2, v1]
//     call @h v1 { nocontinue = true }
//     ; out: [v2]
//     terminated
//
// func @f(args: (v0, v1)) -> 1 {
//     ; spilled: {}
// #0:
//     ; in: [ReturnLabel[1], v1, v0]
//     v0 = arg 0
//     v1 = arg 1
//     v2 = const 0x00
//     ; [ReturnLabel[1], v0, v1, v0]
//     v3 = builtin @add v0, v1
//     ; [ReturnLabel[1], v0, v3]
//     v4 = builtin @sub v3, v0
//     ; out: [v4, ReturnLabel[1]]
//     return v4
// }
//
// func @g(args: ()) -> 0 {
//     ; spilled: {}
// #0:
//     ; in: [ReturnLabel[2]]
//     v0 = const 0x0101
//     v1 = const 0x01
//     ; [ReturnLabel[2], lit0, lit1]
//     builtin @sstore v1, v0
//     ; out: [ReturnLabel[2]]
//     return
// }
//
// func @h(args: (v0)) -> 0 nocontinue {
//     ; spilled: {}
// #0:
//     ; in: [v0]
//     v0 = arg 0
//     v1 = const 0x00
//     ; [FunctionCallReturnLabel[0], lit1, v0]
//     v2 = call @f v0, v1
//     ; [v2]
//     call @h v2 { nocontinue = true }
//     ; out: []
//     terminated
// }
//
// func @i(args: ()) -> 2 {
//     ; spilled: {}
// #0:
//     ; in: [ReturnLabel[4]]
//     v0 = const 0x00
//     v1 = const 0x0202
//     v2 = const 0x0303
//     ; out: [lit1, lit2, ReturnLabel[4]]
//     return v1, v2
// }
//
