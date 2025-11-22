contract Test {
    event subscribable ValueChanged(uint256 newValue);

    function changeValue(uint256 _value) public {
        emit ValueChanged(_value);
    }
}
// ----
// changeValue(uint256): 42 ->
// ~ emit ValueChanged(uint256): 0x2a
