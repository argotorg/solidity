{
    function a() {
        b()
        c()
    }
    function b() { a() }
    function c() { b() }
}
// ----
// <main>: non-recursive
// a: recursive
// b: recursive
// c: recursive
