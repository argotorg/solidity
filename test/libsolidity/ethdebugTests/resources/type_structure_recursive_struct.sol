struct Node {
    uint256 value;
    Node[] children;
    mapping(uint256 => Node) byKey;
}

contract C {
    Node root;
}
// ----
// .resources.types | keys: ["t_array$_t_struct$_Node_$13_storage_$dyn_storage","t_mapping$_t_uint256_$_t_struct$_Node_$13_storage_$","t_struct$_Node_$13_storage","t_uint256"]
// .resources.pointers | keys: ["storage-t_array$_t_struct$_Node_$13_storage_$dyn_storage","storage-t_mapping$_t_uint256_$_t_struct$_Node_$13_storage_$","storage-t_struct$_Node_$13_storage","storage-t_uint256"]
// .resources.types.t_array$_t_struct$_Node_$13_storage_$dyn_storage.contains.type.id: t_struct$_Node_$13_storage
// .resources.types.t_mapping$_t_uint256_$_t_struct$_Node_$13_storage_$.contains.key.type.id: t_uint256
// .resources.types.t_mapping$_t_uint256_$_t_struct$_Node_$13_storage_$.contains.value.type.id: t_struct$_Node_$13_storage
// .resources.types.t_struct$_Node_$13_storage.contains | length: 3
// .resources.types.t_struct$_Node_$13_storage.contains[0].name: value
// .resources.types.t_struct$_Node_$13_storage.contains[0].type.id: t_uint256
// .resources.types.t_struct$_Node_$13_storage.contains[1].name: children
// .resources.types.t_struct$_Node_$13_storage.contains[1].type.id: t_array$_t_struct$_Node_$13_storage_$dyn_storage
// .resources.types.t_struct$_Node_$13_storage.contains[2].name: byKey
// .resources.types.t_struct$_Node_$13_storage.contains[2].type.id: t_mapping$_t_uint256_$_t_struct$_Node_$13_storage_$
