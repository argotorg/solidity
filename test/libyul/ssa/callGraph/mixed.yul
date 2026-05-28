{
    function f() { g() }
    function g() { f() }
    function h() {}
}
// ----
// <main>: non-recursive
// f: recursive
// g: recursive
// h: non-recursive
