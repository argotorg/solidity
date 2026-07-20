{
    function f() { h() }
    function g() { h() }
    function h() {}
}
// ----
// <main>
// f -> h
// g -> h
// h
