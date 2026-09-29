uint64 constant slotnumGlobal = block.slotnum;

contract A {
    uint64 constant slotnum = block.slotnum;
}
// ====
// EVMVersion: >=amsterdam
// ----
// TypeError 8349: (32-45): Initial value for constant variable has to be a constant expression.
// TypeError 8349: (91-104): Initial value for constant variable has to be a constant expression.
