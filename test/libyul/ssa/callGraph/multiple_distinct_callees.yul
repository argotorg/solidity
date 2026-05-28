{
    function f() {
        g()
        h()
    }
    function g() {}
    function h() {}
}
// ----
// <main>: non-recursive
// f: non-recursive
// g: non-recursive
// h: non-recursive
