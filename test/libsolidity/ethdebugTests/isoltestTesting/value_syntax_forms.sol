contract C {
    uint x;
    function f() public { x = 1; }
}
// ----
// .compilation.compiler.name: solc
// .compilation.compiler.name: "solc"
// C.contract.name: C
// C.contract.name: "C"
// C.creation.instructions[0].operation.mnemonic: PUSH1
// C.creation.instructions[0].operation.mnemonic: "PUSH1"
// C.creation.instructions[0].operation.arguments[0]: 0x80
// C.creation.instructions[0].operation.arguments[0]: "0x80"
