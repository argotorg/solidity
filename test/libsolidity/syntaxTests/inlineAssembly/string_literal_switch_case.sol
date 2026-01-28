contract C {
  function f() public pure {
    assembly {
      switch calldataload(0)
      case "1" {}
      case "2" {}
    }
  }
}
