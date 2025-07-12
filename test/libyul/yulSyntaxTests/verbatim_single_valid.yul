{
    // Test that we can provide the correct number of arguments
    let x := 2
    let y := 3
    let t := verbatim(2, 1, "abc", x, y) // Correct: 2 inputs as specified
    let z := verbatim(0, 1, "def") // Correct: 0 inputs as specified
    verbatim(0, 0, "xyz") // Correct: 0 inputs, 0 outputs
}
// ====
// dialect: evm
// ----
