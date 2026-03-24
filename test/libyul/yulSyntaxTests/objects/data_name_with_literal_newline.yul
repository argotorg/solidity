object "A" {
  code {
    sstore(0, datasize("B\nC"))
  }
  data "B
C" hex"1234"
}
// ----
// ParserError 2314: (65-67): Expected 'StringLiteral' but got 'ILLEGAL'
