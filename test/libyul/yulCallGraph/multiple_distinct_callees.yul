{
    function f() {
        g()
        h()
    }
    function g() {}
    function h() {}
}
// ----
// <main>
// f -> g, h
// g
// h
