contract Base {
    address immutable owner = msg.sender;
    function getOwner() public view returns (address) { return owner; }
}

contract C is Base {
    uint256 counter;
    int24 immutable shift;
    bytes4 immutable tag;
    uint64 immutable unread;
    constructor() { shift = -5; tag = 0xdeadbeef; unread = 3; }
    function f() public view returns (int24, bytes4) { return (shift + shift, tag); }
}
// Code offsets vary with the EVM target. The schema tests check them against immutableReferences.
// ----
// C.creation.context.variables | length: 1
// C.creation.context.variables[0].identifier: counter
// C.runtime.context.variables | length: 4
// C.runtime.context.variables[0].identifier: counter
// C.runtime.context.variables[1].identifier: owner
// C.runtime.context.variables[1].type: {"id":"t_address"}
// C.runtime.context.variables[1].pointer: {"length":"0x14","location":"code","offset":"<IGNORE>"}
// C.runtime.context.variables[2].identifier: shift
// C.runtime.context.variables[2].type: {"id":"t_int24"}
// C.runtime.context.variables[2].pointer: {"length":"0x03","location":"code","offset":"<IGNORE>"}
// C.runtime.context.variables[3].identifier: tag
// C.runtime.context.variables[3].type: {"id":"t_bytes4"}
// C.runtime.context.variables[3].pointer: {"length":"0x04","location":"code","offset":"<IGNORE>"}
