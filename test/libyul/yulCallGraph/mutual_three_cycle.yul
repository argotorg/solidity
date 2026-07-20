{
    function f() { g() }
    function g() { h() }
    function h() { f() }
}
// ----
// <main>
// f (recursive) -> g
// g (recursive) -> h
// h (recursive) -> f
