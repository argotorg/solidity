object "A" {
  code {
    pop(datasize("C"))
  }
  data "B" ""
}
// ====
// bytecodeFormat: legacy
// ----
// TypeError 3517: (39-42): Unknown data object "C".
