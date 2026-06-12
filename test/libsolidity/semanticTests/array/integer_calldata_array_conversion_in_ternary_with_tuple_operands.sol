contract C {
    function g_int(uint[] calldata a, uint[] calldata b) public returns(uint, uint, uint, uint) {
        (uint[] calldata r, ) = true ? (a, 0) : (b, 0);
        return (r.length, r[0], r[1], r[2]);
    }

    function g_slice(uint[] calldata a, uint[] calldata b) public returns(uint, uint, uint, uint) {
        (uint[] calldata r, ) = true ? (a[:], 0) : (b[0:1], 0);
        return (r.length, r[0], r[1], r[2]);
    }

    function g_mix_array_slice(uint[] calldata a, uint[] calldata b) public returns(uint, uint, uint, uint) {
        (uint[] calldata r, ) = true ? (a, 0) : (b[:], 0);
        return (r.length, r[0], r[1], r[2]);
    }

    function g_static(uint[3] calldata a, uint[3] calldata b) public returns(uint, uint, uint, uint) {
        (uint[3] calldata r, ) = true ? (a, 0) : (b, 0);
        return (r.length, r[0], r[1], r[2]);
    }
}
// ----
// g_int(uint256[],uint256[]): 0x40, 0xC0, 3, 11111111, 2222222, 888888888, 3, 11111111, 2222222, 888888888 -> 3, 11111111, 2222222, 888888888
// g_slice(uint256[],uint256[]): 0x40, 0xC0, 3, 11111111, 2222222, 888888888, 3, 11111111, 2222222, 888888888 -> 3, 11111111, 2222222, 888888888
// g_mix_array_slice(uint256[],uint256[]): 0x40, 0xC0, 3, 11111111, 2222222, 888888888, 3, 11111111, 2222222, 888888888 -> 3, 11111111, 2222222, 888888888
// g_static(uint256[3],uint256[3]): 11111111, 2222222, 888888888, 11111111, 2222222, 888888888 -> 3, 11111111, 2222222, 888888888
