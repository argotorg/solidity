contract Test {
    event subscribable DataRecorded(
        address indexed user,
        uint256 timestamp,
        bytes32 dataHash
    ) gasHint(80000);

    function recordData(bytes32 _dataHash) public {
        emit DataRecorded(msg.sender, block.timestamp, _dataHash);
    }
}
// ----
// recordData(bytes32): 0xabcd ->
// ~ emit DataRecorded(address,uint256,bytes32): #0x1212121212121212121212121212120000000012
