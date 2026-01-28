bytes constant aaaa = hex"aaaa";

bytes constant abcGlobal = bytes.concat(aaaa, hex"bbbb", hex"cccc");

contract A {
    bytes public constant abc = bytes.concat(aaaa, hex"bbbb", hex"cccc");

    bytes public constant abcCopy = abc;
    bytes public constant abcGlobalCopy = abcGlobal;
    bytes public constant abcabc = bytes.concat(abc, abcGlobal);
}
