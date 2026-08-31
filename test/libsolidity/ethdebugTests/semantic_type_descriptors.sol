type Amount is uint128;

enum Choice { A, B, C }

contract C {
    struct Node {
        uint256 value;
        Node[] children;
    }

    Amount amount;
    Choice choice;
    Node root;
    C self;
}
// ----
// C.semantic.scopes.27.0.variableDefinitions | length: 4
// C.semantic.resources.pointers | keys: ["storage_27_17", "storage_27_20", "storage_27_23", "storage_27_26"]
// C.semantic.scopes.27.0.variableDefinitions[0].identifier: amount
// C.semantic.scopes.27.0.variableDefinitions[0].typeID: t_userDefinedValueType$_Amount_$3
// C.semantic.scopes.27.0.variableDefinitions[0].pointer.template: storage_27_17
// C.semantic.resources.types.t_userDefinedValueType$_Amount_$3.kind: alias
// C.semantic.resources.types.t_userDefinedValueType$_Amount_$3.definition.name: Amount
// C.semantic.resources.types.t_userDefinedValueType$_Amount_$3.definition.location.source.id: 0
// C.semantic.resources.types.t_userDefinedValueType$_Amount_$3.contains.type.id: t_uint128
// C.semantic.resources.types.t_uint128.kind: uint
// C.semantic.resources.types.t_uint128.bits: 128
// C.semantic.scopes.27.0.variableDefinitions[1].identifier: choice
// C.semantic.resources.types.t_enum$_Choice_$7.kind: enum
// C.semantic.resources.types.t_enum$_Choice_$7.values: ["A", "B", "C"]
// C.semantic.scopes.27.0.variableDefinitions[2].identifier: root
// C.semantic.resources.types.t_struct$_Node_$14_storage.kind: struct
// C.semantic.resources.types.t_struct$_Node_$14_storage.contains[1].name: children
// C.semantic.resources.types.t_array$_t_struct$_Node_$14_storage_$dyn_storage_ptr.kind: array
// C.semantic.resources.types.t_array$_t_struct$_Node_$14_storage_$dyn_storage_ptr.contains.type.id: t_struct$_Node_$14_storage
// C.semantic.scopes.27.0.variableDefinitions[3].identifier: self
// C.semantic.resources.types.t_contract$_C_$27.kind: contract
// C.semantic.resources.types.t_contract$_C_$27.definition.name: C
