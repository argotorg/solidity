// Accessors return the whole struct, including its dynamically-sized members.
contract C {
    struct S {
        uint256 x;
        string a;
        uint256[] b;
        uint256 y;
    }
    S public s;

    function g() public returns (uint256, uint256) {
        s.x = 2;
        s.a = "abc";
        s.b = [7, 8, 9];
        s.y = 6;
        S memory r = this.s();
        return (r.x, r.y);
    }
}
// ----
// g() -> 2, 6
// gas irOptimized: 180436
// gas legacy: 185234
// gas legacyOptimized: 181350
// gas ssaCFGOptimized: 180367
