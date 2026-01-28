object "A" {
  code {
    pop(dataoffset("C"))
  }
  data "B" ""
}
// ====
// bytecodeFormat: legacy
// ----
// TypeError 3517: (41-44): Unknown data object "C".
