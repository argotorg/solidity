{
    function f() { h() }
    function g() { h() }
    function h() {}
}
// ----
// <main>: non-recursive
// f: non-recursive
// g: non-recursive
// h: non-recursive
