{
    function f(a, b) -> r {
        let x := add(a,b)
        r := sub(x,a)
    }
    function g() {
        function z() -> r {
            function w() -> rw1 {
                rw1 := 0x01
            }
            r := w()
        }
        function v() -> r {
            function w() -> rw2 {
                rw2 := 0x11
            }
            r := w()
        }
        sstore(z(), f(v(),2))
    }
    function cycle1() -> r {
        if mload(3) {
            r := cycle2()
        }
    }
    function cycle2() -> r {
        if mload(4) {
            r := cycle1()
        }
    }
}
// ----
// #0:
//     ; dfs 0..0
//     ; live-in:
//     ; live-out:
//     ; used:
//     main_exit
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
//     v0 = const 0x02
//     v1 = call @v
//     v2 = call @f v1, v0
//     v3 = call @z
//     builtin @sstore v3, v2
//     return
// }
//
// func @cycle1(args: ()) -> 1 {
// #0:
//     ; dfs 0..3
//     ; live-in:
//     ; live-out:
//     ; used:
//     v0 = const 0x00
//     v1 = const 0x03
//     v2 = builtin @mload v1
//     branch v2, #1, #3
// #1: preds: #0
//     ; dfs 1..2
//     ; live-in:
//     ; live-out: v3[1]
//     ; used:
//     v3 = call @cycle2
//     upsilon v3 -> ^v4
//     jump #2
// #2: preds: #3, #1
//     ; dfs 2..2
//     ; live-in: phi4[3]
//     ; live-out: phi4[1]
//     ; used: phi4[2]
//     v4 = phi
//     return v4
// #3: preds: #0
//     ; dfs 3..3
//     ; live-in:
//     ; live-out:
//     ; used:
//     upsilon v0 -> ^v4
//     jump #2
// }
//
// func @cycle2(args: ()) -> 1 {
// #0:
//     ; dfs 0..3
//     ; live-in:
//     ; live-out:
//     ; used:
//     v0 = const 0x00
//     v1 = const 0x04
//     v2 = builtin @mload v1
//     branch v2, #1, #3
// #1: preds: #0
//     ; dfs 1..2
//     ; live-in:
//     ; live-out: v3[1]
//     ; used:
//     v3 = call @cycle1
//     upsilon v3 -> ^v4
//     jump #2
// #2: preds: #3, #1
//     ; dfs 2..2
//     ; live-in: phi4[3]
//     ; live-out: phi4[1]
//     ; used: phi4[2]
//     v4 = phi
//     return v4
// #3: preds: #0
//     ; dfs 3..3
//     ; live-in:
//     ; live-out:
//     ; used:
//     upsilon v0 -> ^v4
//     jump #2
// }
//
// func @z(args: ()) -> 1 {
// #0:
//     ; dfs 0..0
//     ; live-in:
//     ; live-out: v1[1]
//     ; used:
//     v0 = const 0x00
//     v1 = call @w
//     return v1
// }
//
// func @v(args: ()) -> 1 {
// #0:
//     ; dfs 0..0
//     ; live-in:
//     ; live-out: v1[1]
//     ; used:
//     v0 = const 0x00
//     v1 = call @w
//     return v1
// }
//
// func @w(args: ()) -> 1 {
// #0:
//     ; dfs 0..0
//     ; live-in:
//     ; live-out:
//     ; used:
//     v0 = const 0x00
//     v1 = const 0x01
//     return v1
// }
//
// func @w(args: ()) -> 1 {
// #0:
//     ; dfs 0..0
//     ; live-in:
//     ; live-out:
//     ; used:
//     v0 = const 0x00
//     v1 = const 0x11
//     return v1
// }
//
