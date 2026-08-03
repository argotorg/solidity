{
    function f() {
        mstore(0, 1)
    }
    f()
}
// ----
// <main> -> f
// f -> mstore
