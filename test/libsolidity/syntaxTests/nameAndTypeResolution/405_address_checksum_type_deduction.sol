contract C {
    function f() public {
        payable(0xfA0bFc97E48458494Ccd857e1A85DC91F7F0046E).transfer(2);
    }
}
// ----
// Warning 9207: (47-107): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
