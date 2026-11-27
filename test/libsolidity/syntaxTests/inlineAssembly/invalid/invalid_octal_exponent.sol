contract C {
  function f() public pure {
    assembly {
      let x := 1e010
    }
  }
}
// ----
// ParserError 1465: (72-74): Illegal token: Octal numbers not allowed.
