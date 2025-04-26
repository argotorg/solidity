{
    // Using variables as arguments which should be literals
    let n := 2
    let m := 1
    let c := "abc"
    let x := verbatim(n, m, c)
}
// ====
// dialect: evm
// ----
// TypeError 9114: (92-112): Function expects direct literals as arguments.
