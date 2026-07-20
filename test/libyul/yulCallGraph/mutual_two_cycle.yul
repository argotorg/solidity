{
    function f() { g() }
    function g() { f() }
}
// ----
// <main>
// f (recursive) -> g
// g (recursive) -> f
