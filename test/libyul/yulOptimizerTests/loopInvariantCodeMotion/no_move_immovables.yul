{
    function f() -> x {invalid()}
    function g() -> y {return(0, 0)}
    for { let a := 1 } iszero(eq(a, 10)) { a := add(a, 1) } {
        let b := f()
        let d := g()
        let e := sload(g())
    }
}
// ----
// step: loopInvariantCodeMotion
//
// {
//     let a := 1
//     for { } iszero(eq(a, 10)) { a := add(a, 1) }
//     {
//         let b := f()
//         let d := g()
//         let e := sload(g())
//     }
//     function f() -> x
//     { invalid() }
//     function g() -> y
//     { return(0, 0) }
// }
