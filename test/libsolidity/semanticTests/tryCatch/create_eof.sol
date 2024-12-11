contract Reverts {
    constructor(uint) { revert("test message."); }
}
contract Succeeds {
    constructor(uint) { }
}

contract C {
    function f() public returns (Reverts x, uint, string memory txt) {
        uint i = 3;
        try new Reverts(i) returns (Reverts r) {
            x = r;
            txt = "success";
        } catch Error(string memory s) {
            txt = s;
        }
    }
    function g() public returns (Succeeds x, uint, string memory txt) {
        uint i = 8;
        try new Succeeds(i) returns (Succeeds r) {
            x = r;
            txt = "success";
        } catch Error(string memory s) {
            txt = s;
        }
    }
}
// ====
// EVMVersion: >=byzantium
// bytecodeFormat: >=EOFv1
// EVMVersion: >=prague
// ----
// f() -> 0, 0, 96, 13, "test message."
// g() -> 0x79E227549940F29566EB81846A858E6F4108C430, 0, 96, 7, "success"
