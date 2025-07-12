{
    // Test what happens when we provide fewer function arguments than specified in the first parameter
    let x := 2
    let t := verbatim(2, 1, "abc", x) // Expecting 2 inputs but only given 1
}
// ====
// dialect: evm
// ----
// TypeError 4323: (121-142): Function expects 5 arguments but got 4.
