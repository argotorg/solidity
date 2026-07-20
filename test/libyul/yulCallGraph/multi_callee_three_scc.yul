{
    function a() {
        b()
        c()
    }
    function b() { a() }
    function c() { b() }
}
// ----
// <main>
// a (recursive) -> b, c
// b (recursive) -> a
// c (recursive) -> b
