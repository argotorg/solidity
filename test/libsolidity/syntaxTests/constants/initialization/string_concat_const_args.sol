string constant abcGlobal = string.concat("aaaa", "bbbb", "cccc");

contract A {
    string public constant abc = string.concat("aaaa", "bbbb","cccc");

    string public constant abcCopy = abc;
    string public constant abcGlobalCopy = abcGlobal;
    string public constant abcabc = string.concat(abc, abcGlobal);
}
