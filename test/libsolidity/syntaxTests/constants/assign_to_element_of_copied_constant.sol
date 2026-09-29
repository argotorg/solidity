bytes constant B = "abc";

contract C {
    struct S { uint a; }

    function f(uint x) public pure returns (bytes memory) {
        bytes memory b = B;
        b[0] = "x";
        [x][0] = 1;
        abi.encode(x)[0] = 0x01;
        S(x).a = 2;
        return b;
    }
}
