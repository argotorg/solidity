{
    function f() {
        g()
        g()
    }
    function g() {}
}
// ----
// <main>
// f -> g
// g
