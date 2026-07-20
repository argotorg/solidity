{
    function f() { g() }
    function g() { f() }
    function h() {}
}
// ----
// <main>
// f (recursive) -> g
// g (recursive) -> f
// h
