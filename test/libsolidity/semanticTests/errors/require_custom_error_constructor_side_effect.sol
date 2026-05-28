// The purpose of this test is to check that the side-effect of
// the error parameter occurs, i.e, MyError is constructed with errorCode = 1
// and also confirm the state is properly reverted
contract C {
    error MyError(uint errorCode);
    uint public counter = 0;
    function count() public returns (uint) { return ++counter; }
    function f() external {
        require(false, MyError(count()));
        counter = 42;
    }
}
// ----
// f() -> FAILURE, hex"30b1b565", 1
// counter() -> 0
