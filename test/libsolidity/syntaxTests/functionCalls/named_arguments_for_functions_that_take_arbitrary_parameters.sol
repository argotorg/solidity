contract C {
    function f() pure public {
        abi.encodeWithSelector({selector:"abc"});
        bytes.concat({x: "abc"});
        string.concat({x: "abc"});
    }
}
// ----
// TypeError 2627: (52-92): Named arguments cannot be used for functions that take arbitrary parameters.
// TypeError 7101: (102-126): Named arguments cannot be used for functions that take arbitrary parameters.
// TypeError 7173: (136-161): Named arguments cannot be used for functions that take arbitrary parameters.
