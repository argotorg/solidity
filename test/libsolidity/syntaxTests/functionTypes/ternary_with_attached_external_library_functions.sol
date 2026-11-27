library L {
    function f(uint a) external view returns (uint) { return 1; }
    function g(uint a) public pure returns (uint) { return 2; }
}
contract C {
    using L for *;
    function f(bool x) view public {
        uint t = 8;
        (x ? t.f : t.g)();
    }
}
// ----
// TypeError 9717: (246-249): Invalid mobile type in true expression.
// TypeError 3703: (252-255): Invalid mobile type in false expression.
