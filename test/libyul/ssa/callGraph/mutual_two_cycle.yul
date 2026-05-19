{
    function f() { g() }
    function g() { f() }
}
// ----
// <main>: non-recursive
// f: recursive
// g: recursive
