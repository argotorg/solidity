contract C {
    uint public x;
    function set(uint _x) public {
        x = _x;
    }
    function get() public view returns (uint) {
        return x;
    }
}
// ----
// .compilation.compiler.name: solc
// .resources.compilation.sources | length: 1
// .resources.compilation.sources[0].id: 0
//
// C.contract.name: C
// C.creation.environment: create
// C.contract.definition.source.id: 0
// C.creation.instructions[0].offset: 0
// C.creation.instructions[0].operation.mnemonic: PUSH1
// C.creation.instructions[0].operation.arguments[0]: 0x80
// C.creation.instructions[2].operation.mnemonic: MSTORE
//
// C.runtime.contract.name: C
// C.runtime.environment: call
