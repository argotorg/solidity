contract C {
    constructor() payable {
        payable(address(0x1234)).transfer(500);
    }
}
// ----
// constructor(), 2000 wei ->
// balance -> 1500
// balance: 0x0000000000000000000000000000000000001234 -> 500
