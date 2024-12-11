contract C {
    function f() public view returns (address a1, address a2) {
        a1 = this.f.address;
        this.f.address;
        [this.f.address][0];
        a2 = [this.f.address][0];
    }
}
// ====
// EVMVersion: >=prague
// bytecodeFormat: >=EOFv1
// ----
// f() -> 0xc19c03f456eb6e9b1d3e41daa69053e44bdbd949, 0xc19c03f456eb6e9b1d3e41daa69053e44bdbd949
