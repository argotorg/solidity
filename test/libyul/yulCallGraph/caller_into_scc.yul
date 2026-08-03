{
    function f() { g() }
    function g() { h() }
    function h() { g() }
}
// ----
// <main>
// f -> g
// g (recursive) -> h
// h (recursive) -> g
