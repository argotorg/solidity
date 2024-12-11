contract C {
    function f() public view returns (address a1, address a2) {
        a1 = this.f.address;
        this.f.address;
        [this.f.address][0];
        a2 = [this.f.address][0];
    }

    function checkAddress() public returns (bool) {
        address a1;
        address a2;
        (a1, a2) = f();
        return (a1 != address(0) && a1 == a2);
    }
}
// ====
// EVMVersion: >=prague
// bytecodeFormat: >=EOFv1
// ----
// checkAddress() -> true
