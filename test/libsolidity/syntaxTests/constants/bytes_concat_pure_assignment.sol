bytes constant abcGlobal = bytes.concat(
    hex"aaaa",
    hex"bbbb",
    hex"cccc"
);

contract A {
    bytes public constant abc = bytes.concat(
        hex"aaaa",
        hex"bbbb",
        hex"cccc"
    );

    bytes public constant abcCopy = abc;
    bytes public constant abcGlobalCopy = abcGlobal;
    bytes public constant abcabc = bytes.concat(abc, abcGlobal);
}
