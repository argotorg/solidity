contract C {
    function f(uint x) external payable returns (uint) { return 1; }
    function f(uint x, uint y) external payable returns (uint) { return 2; }
    function call() public payable returns (uint x, uint y) {
        x = this.f{value: 10}(2);
        y = this.f{value: 10}(2, 3);
    }
    function bal() external returns (uint) { return address(this).balance; }
    receive() external payable {}
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// (), 1 ether
// call() -> 1, 2
// bal() -> 1000000000000000000
