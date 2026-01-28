contract C {
  function f() public pure {
    assembly {
      switch calldataload(0)
      case hex"00" {}
      case hex"1122" {}
    }
  }
}
