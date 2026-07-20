{
    function f() {
        g()
        h()
    }
    function g() { f() }
    function h() {}
}
// ----
// <main>
// f (recursive) -> g, h
// g (recursive) -> f
// h
