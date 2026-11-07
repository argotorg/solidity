library L {
    function f(bool b, uint x) public pure returns (uint) {
        if (b) {
            return x + 1;
        } else {
            revert("function f reverted");
        }
    }
    function g(bool b, uint x) external view returns (uint) {
        if (b) {
            return x + block.number / block.number;
        } else {
            revert("function g reverted");
        }
    }
}
contract C {
    function test(bool b1, bool b2) public returns (uint, string memory) {
        try (b1 ? L.f : L.g)(b2, 8) returns (uint x) {
            return (x, "success");
        } catch Error(string memory message) {
            return (0, message);
        }
    }
}
// ====
// EVMVersion: >=byzantium
// ----
// library: L
// test(bool,bool): true, true -> 9, 0x40, 7, "success"
// test(bool,bool): true, false -> 0, 0x40, 0x13, "function f reverted"
// test(bool,bool): false, true -> 9, 0x40, 7, "success"
// test(bool,bool): false, false -> 0, 0x40, 0x13, "function g reverted"
