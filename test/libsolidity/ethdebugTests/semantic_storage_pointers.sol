contract C {
    struct Item {
        uint128 first;
        uint64 second;
    }

    mapping(address => mapping(uint256 => Item)) balances;
    uint16[8] packed;
    uint256[] dynamicValues;
    string label;
    uint128 transient transientValue;
}
// ====
// EVMVersion: >=cancun
// ----
// C.semantic.scopes | keys: ["25"]
// C.semantic.scopes.25.0.variableDefinitions | length: 5
// C.semantic.resources.pointers | keys: ["storage_25_13", "storage_25_17", "storage_25_20", "storage_25_22", "transient_25_24"]
// C.semantic.scopes.25.0.variableDefinitions[0].identifier: balances
// C.semantic.scopes.25.0.variableDefinitions[0].phase: materialized
// C.semantic.scopes.25.0.variableDefinitions[0].pointer.template: storage_25_13
// C.semantic.resources.pointers.storage_25_13.expect: ["key", "key1"]
// C.semantic.resources.pointers.storage_25_13.for.group[0].location: storage
// C.semantic.resources.pointers.storage_25_13.for.group[0].slot.$keccak256 | length: 2
// C.semantic.scopes.25.0.variableDefinitions[0].typeID: t_mapping$_t_address_$_t_mapping$_t_uint256_$_t_struct$_Item_$6_storage_$_$
// C.semantic.resources.types.t_mapping$_t_address_$_t_mapping$_t_uint256_$_t_struct$_Item_$6_storage_$_$.kind: mapping
// C.semantic.resources.types.t_struct$_Item_$6_storage.kind: struct
// C.semantic.scopes.25.0.variableDefinitions[1].identifier: packed
// C.semantic.scopes.25.0.variableDefinitions[1].pointer.template: storage_25_17
// C.semantic.resources.pointers.storage_25_17.expect: []
// C.semantic.resources.pointers.storage_25_17.for.list.count: 0x08
// C.semantic.resources.pointers.storage_25_17.for.list.is.offset.$product | length: 2
// C.semantic.resources.types.t_array$_t_uint16_$8_storage.count: 0x08
// C.semantic.scopes.25.0.variableDefinitions[2].identifier: dynamicValues
// C.semantic.scopes.25.0.variableDefinitions[2].pointer.template: storage_25_20
// C.semantic.resources.pointers.storage_25_20.for.group[1].define.dynamicValues-data.$keccak256 | length: 1
// C.semantic.resources.pointers.storage_25_20.for.group[1].in.list.count.$read: dynamicValues-length
// C.semantic.scopes.25.0.variableDefinitions[3].identifier: label
// C.semantic.scopes.25.0.variableDefinitions[3].pointer.template: storage_25_22
// C.semantic.resources.pointers.storage_25_22.for.group[1].if.$remainder | length: 2
// C.semantic.resources.pointers.storage_25_22.for.group[1].then.define.label-length.$quotient | length: 2
// C.semantic.resources.types.t_string_storage.kind: string
// C.semantic.scopes.25.0.variableDefinitions[4].identifier: transientValue
// C.semantic.scopes.25.0.variableDefinitions[4].pointer.template: transient_25_24
// C.semantic.resources.pointers.transient_25_24.for.location: transient
