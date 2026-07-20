{
    function outer() {
        function inner() {
            for {} 1 {} {}
            outer()
        }
        inner()
    }
    outer()
}
// ----
// <main> -> outer
// outer (recursive) -> inner
// inner (recursive, loops) -> outer
