contract Test {
    event subscribable Transfer(address indexed from, address indexed to, uint256 value) gasHint(100000);

    function transfer(address to, uint256 value) public {
        emit Transfer(msg.sender, to, value);
    }
}
// ----
// transfer(address,uint256): 0x1234567890123456789012345678901234567890, 100 ->
// ~ emit Transfer(address,address,uint256): #0x1212121212121212121212121212120000000012, #0x1234567890123456789012345678901234567890, 0x64
