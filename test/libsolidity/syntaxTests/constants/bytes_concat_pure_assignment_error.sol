contract A {
    function getData() public view returns (bytes memory) {
        return msg.data;
    }

    bytes constant abData = bytes.concat(
        hex"aaaa",
        hex"bbbb",
        msg.data
    );

    bytes constant abgetData = bytes.concat(
        hex"aaaa",
        hex"bbbb",
        getData()
    );
}
// ----
// TypeError 8349: (133-207): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (241-316): Initial value for constant variable has to be compile-time constant.
