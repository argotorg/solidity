{
    function f() { f() }
    function g() { h() }
    function h() { g() }
}
// ----
// <main>
// f (recursive) -> f
// g (recursive) -> h
// h (recursive) -> g
