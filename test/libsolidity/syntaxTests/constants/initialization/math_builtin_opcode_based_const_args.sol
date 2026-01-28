uint256 constant k = 7;
bytes constant data = hex"ffff";

uint256 constant amodGlobal = addmod(1, 8, k);
uint256 constant mmodGlobal = mulmod(1, 8, k);
bytes32 constant keccakGlobal = keccak256(hex"ffff");
bytes32 constant keccakConstArgGlobal = keccak256(data);

contract A {
    uint256 constant amod = addmod(1, 8, k);
    uint256 constant mmod = mulmod(1, 8, k);
    bytes32 constant keccak = keccak256(hex"ffff");
    bytes32 constant keccakConstArg = keccak256(data);
}
