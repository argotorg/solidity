{
    function f() {
        f()
        g()
    }
    function g() {}
}
// ----
// <main>
// f (recursive) -> f, g
// g
