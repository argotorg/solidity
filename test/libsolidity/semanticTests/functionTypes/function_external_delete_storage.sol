contract C {
    function() external public x;

    function f() public {}

    function set() external {
        x = this.f;
    }

    function isF() external returns (bool) {
        return x == this.f;
    }

    function isZero() external returns (bool) {
        function() external zero;
        return x == zero;
    }

    function deleteFunction() public {
        // used to lead to an ICE during IR
        delete x;
    }
}
// ----
// isF() -> false
// isZero() -> true
// deleteFunction() ->
// isF() -> false
// isZero() -> true
// set() ->
// isF() -> true
// isZero() -> false
// deleteFunction() ->
// isF() -> false
// isZero() -> true
