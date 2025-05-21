contract A {
    function f() external pure returns (uint) {}
}
contract C is A layout at this.f{}() {}
// ----
// ParserError 7858: (98-99): Expected pragma, import directive or contract/interface/library/struct/enum/constant/function/error definition.
