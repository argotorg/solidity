contract C {
    // Each element occupies 2^255 storage slots.
    // push() computes the new element's slot as: keccak256(data.slot) + index * storageSize
    // The 3rd push (index 2) overflows: 2 * 2^255 = 2^256 mod 2^256 = 0.
    uint256[2**255][] data;

    function test() public {
        data.push();
        data.push();
        data.push();
    }
}
// ----
// test() -> FAILURE, hex"4e487b71", 0x11
