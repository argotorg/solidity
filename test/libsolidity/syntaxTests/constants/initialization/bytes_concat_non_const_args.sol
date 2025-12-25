contract A {
    function getData() public view returns (bytes memory) {
        return msg.data;
    }

    function getDataPure() public pure returns (bytes memory) {
        return hex"ffff";
    }

    bytes constant abData = bytes.concat(hex"aaaa", hex"bbbb", msg.data);
    bytes constant abgetData = bytes.concat(hex"aaaa", hex"bbbb", getData());
    bytes constant abgetDataPure = bytes.concat(hex"aaaa", hex"bbbb", getDataPure());
}
// ----
// TypeError 8349: (230-274): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (307-352): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (389-438): Initial value for constant variable has to be compile-time constant.
