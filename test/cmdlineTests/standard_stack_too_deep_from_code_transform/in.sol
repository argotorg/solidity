contract C {
    function f() public {
        uint b;
        abi.encodePacked(
            b, b, b, b, b, b, b, b,
            b, b, b, b, b, b, b, b,
            b, b, b, b, b, b, b, b
        );
    }
}
