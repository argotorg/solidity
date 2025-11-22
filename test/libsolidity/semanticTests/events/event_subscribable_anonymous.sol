contract Test {
    event subscribable anonymous ValueSet(uint256 value) gasHint(30000);

    function setValue(uint256 _value) public {
        emit ValueSet(_value);
    }
}
// ----
// setValue(uint256): 123 ->
// ~ emit <anonymous>
