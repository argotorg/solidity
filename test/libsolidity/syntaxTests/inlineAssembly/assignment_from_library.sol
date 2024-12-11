library L {
}

contract C {
  function f() public pure {
    assembly {
      let x := L
    }
  }
}
// ====
// bytecodeFormat: legacy
// ----
