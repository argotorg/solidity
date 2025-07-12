{
    let x := 2
    let y := sub(x, 2)
    // Using the new verbatim builtin with literal args instead of verbatim_2i_1o
    let r := verbatim(0, 1, "def") // No input arguments, 1 output value
    let t := verbatim(2, 1, "abc", x, y) // 2 input arguments, 1 output value
    sstore(t, x)
    verbatim(0, 0, "xyz") // No input arguments, no output values
    // more than 32 bytes
    verbatim(0, 0, hex"01020304050607090001020304050607090001020304050607090001020102030405060709000102030405060709000102030405060709000102")
}
