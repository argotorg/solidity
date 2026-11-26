{
    function spin() { for {} 1 {} { } }
    function wrapper(b) -> s {
        if b { s := 1 }
        spin()
        s := add(s, b)
    }
    function recurse(c) { if 1 { recurse(c) } }
    function two(a) -> x, y { x := a y := a }
    sstore(1, wrapper(calldataload(0)))
    // dead: a call with two outputs, a memoryguard and a call to a function that only recurses
    let p, q := two(calldataload(1))
    mstore(64, memoryguard(128))
    sstore(p, q)
    recurse(2)
}
// ----
// memoryguard = 0x80
//
// #0:
//     v0 = const 0x00
//     v1 = builtin @calldataload v0
//     v2 = call @wrapper v1
//     terminated
//
// func @spin(args: ()) -> 0 {
// #0:
//     v0 = const 0x01
//     jump #1
// #1: preds: #0, #1
//     jump #1
// }
//
// func @wrapper(args: (v0)) -> 1 {
// #0:
//     v0 = arg 0
//     v1 = const 0x00
//     v2 = const 0x01
//     branch v0, #1, #2
// #1: preds: #0
//     jump #2
// #2: preds: #0, #1
//     call @spin
//     terminated
// }
//
// func @recurse(args: (v0)) -> 0 {
// #0:
//     v0 = arg 0
//     v1 = const 0x01
//     call @recurse v0
//     terminated
// }
//
// func @two(args: (v0)) -> 2 {
// #0:
//     v0 = arg 0
//     v1 = const 0x00
//     return v0, v0
// }
//
