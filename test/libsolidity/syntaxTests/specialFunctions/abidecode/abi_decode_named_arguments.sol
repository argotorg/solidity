contract C {
    function f(bytes memory d) public pure {
        abi.decode({bogus: d, alsoBogus: (uint)});
        abi.decode({bogus: d});
    }
}
// ----
// TypeError 5738: (66-107): Named arguments cannot be used for functions that take arbitrary parameters.
// TypeError 5738: (117-139): Named arguments cannot be used for functions that take arbitrary parameters.
