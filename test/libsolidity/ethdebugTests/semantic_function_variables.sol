contract C {
    modifier guarded(bool enabled) {
        require(enabled);
        _;
    }

    function f(uint256 value, bytes memory payload)
        public
        pure
        guarded(true)
        returns (uint256 result, bytes memory)
    {
        return (value, payload);
    }
}
// ----
// C.semantic.format: solidity-ethdebug-semantic-data
// C.semantic.version: 1
// C.semantic.scopes | keys: ["11", "30"]
// C.semantic.resources.pointers | keys: []
// C.semantic.scopes.11.0.variableDefinitions | length: 1
// C.semantic.scopes.11.0.variableDefinitions[0].identifier: enabled
// C.semantic.scopes.11.0.variableDefinitions[0].phase: materialized
// C.semantic.scopes.11.0.variableDefinitions[0].pointer.location: stack
// C.semantic.scopes.11.0.variableDefinitions[0].pointer.slot.$$yulLocal: var_enabled_3
// C.semantic.scopes.11.0.variableDefinitions[0].typeID: t_bool
// C.semantic.resources.types.t_bool.kind: bool
// C.semantic.scopes.30.0.variableDefinitions | length: 4
// C.semantic.scopes.30.0.variableDefinitions[0].identifier: value
// C.semantic.scopes.30.0.variableDefinitions[0].declarationSourceRange.source.id: 0
// C.semantic.scopes.30.0.variableDefinitions[0].typeID: t_uint256
// C.semantic.resources.types.t_uint256.kind: uint
// C.semantic.resources.types.t_uint256.bits: 256
// C.semantic.scopes.30.0.variableDefinitions[1].identifier: payload
// C.semantic.scopes.30.0.variableDefinitions[1].typeID: t_bytes_memory_ptr
// C.semantic.resources.types.t_bytes_memory_ptr.kind: bytes
// C.semantic.scopes.30.0.variableDefinitions[2].identifier: result
// C.semantic.scopes.30.0.variableDefinitions[3].identifier: <PATH NOT FOUND>
// C.semantic.scopes.30.0.variableDefinitions[3].declarationASTID: <IGNORE>
// C.semantic.scopes.30.0.variableDefinitions[3].phase: materialized
// C.semantic.scopes.30.0.variableDefinitions[3].pointer.name: <PATH NOT FOUND>
// C.semantic.scopes.30.0.variableDefinitions[3].pointer.location: stack
// C.semantic.scopes.30.0.variableDefinitions[3].typeID: t_bytes_memory_ptr
