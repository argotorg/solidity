{
    function f() { g() mstore(0, 1) }
    function g() { f() }
}
// ----
// <main>
// f (recursive) -> g, mstore
// g (recursive) -> f
