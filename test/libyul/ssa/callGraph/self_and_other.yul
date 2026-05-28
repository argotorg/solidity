{
    function f() {
        f()
        g()
    }
    function g() {}
}
// ----
// <main>: non-recursive
// f: recursive
// g: non-recursive
