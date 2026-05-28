{
    function f() { g() }
    function g() { h() }
    function h() { f() }
}
// ----
// <main>: non-recursive
// f: recursive
// g: recursive
// h: recursive
