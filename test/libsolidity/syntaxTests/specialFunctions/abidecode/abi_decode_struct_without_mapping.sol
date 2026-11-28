struct S {
    uint a;
    uint[2] b;
}
contract C {
    function f(bytes memory data) public pure {
        abi.decode(data, (S));
        abi.decode(data, (S[]));
    }
}
