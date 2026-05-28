{
    function f() {
        g()
        g()
    }
    function g() {}
}
// ----
// <main>: non-recursive
// f: non-recursive
// g: non-recursive
