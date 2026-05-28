{
    function f() { g() }
    function g() { h() }
    function h() { g() }
}
// ----
// <main>: non-recursive
// f: non-recursive
// g: recursive
// h: recursive
