{
    // Intersecting recursive cycles e -> b -> d -> e and e -> c -> d -> e share {d, e}, so the whole
    // {e, b, c, d} set is a single strongly-connected component and all of them are recursive.
    // In particular c() must be recognized as recursive and therefore left un-specialized, despite the
    // constant call site c(10). This is a regression test for the call graph cycle-detection bug that
    // misclassified some members of intersecting cycles as non-recursive: specializing c(10) here would
    // produce code that is not equivalent to the original.
    function e(n) {
        if eq(n, 0) { leave }
        b(sub(n, 1))
        c(sub(n, 1))
    }
    function b(n) { d(sub(n, 1)) }
    function c(n) { d(sub(n, 1)) }
    function d(n) { e(sub(n, 1)) }
    c(10)
}
// ----
// step: functionSpecializer
//
// {
//     c(10)
//     function e(n)
//     {
//         if eq(n, 0) { leave }
//         b(sub(n, 1))
//         c(sub(n, 1))
//     }
//     function b(n_1)
//     { d(sub(n_1, 1)) }
//     function c(n_2)
//     { d(sub(n_2, 1)) }
//     function d(n_3)
//     { e(sub(n_3, 1)) }
// }
