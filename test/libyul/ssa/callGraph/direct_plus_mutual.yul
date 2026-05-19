{
    function f() { f() }
    function g() { h() }
    function h() { g() }
}
// ----
// <main>: non-recursive
// f: recursive
// g: recursive
// h: recursive
