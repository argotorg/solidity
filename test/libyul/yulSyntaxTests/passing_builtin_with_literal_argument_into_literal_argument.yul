{
    setimmutable(0, loadimmutable("abc"), "abc")
}
// ====
// dialect: evm
// bytecodeFormat: legacy
// ----
// TypeError 9114: (6-18): Function expects direct literals as arguments.
