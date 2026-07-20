{
    function f() { g() }
    function g() { h() }
    function h() {}
}
// ----
// <main>
// f -> g
// g -> h
// h
