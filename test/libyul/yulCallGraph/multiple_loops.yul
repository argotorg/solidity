{
    for {} 1 {} {}
    function f() {
        for {} 1 {} {
            for {} 1 {} {}
        }
    }
    function g() {}
}
// ----
// <main> (loops)
// f (loops)
// g
