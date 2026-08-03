{
    // Nested function definitions with a cycle a -> b -> c -> a.
    function a() {
        function b() {
            function c() { a() }
            c()
        }
        b()
    }
    a()
}
// ----
// <main> -> a
// a (recursive) -> b
// b (recursive) -> c
// c (recursive) -> a
