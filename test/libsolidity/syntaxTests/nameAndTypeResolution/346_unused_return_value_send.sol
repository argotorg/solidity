contract test {
    function f() public {
        payable(address(0x12)).send(1);
    }
}
// ----
// Warning 9207: (50-77): 'send' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Warning 5878: (50-80): Failure condition of 'send' ignored. Consider using 'transfer' instead.
