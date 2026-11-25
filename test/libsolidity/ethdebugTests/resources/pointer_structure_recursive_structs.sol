struct Node {
    uint256 value;
    uint256 extra;
    Node[] children;
}

struct Leaf {
    uint256 value;
    mapping(uint256 => Leaf) byKey;
}

contract C {
    Node tree;
    Leaf leaf;
}
// ----
// .resources.types | keys: ["t_array$_t_struct$_Node_$10_storage_$dyn_storage","t_mapping$_t_uint256_$_t_struct$_Leaf_$18_storage_$","t_struct$_Leaf_$18_storage","t_struct$_Node_$10_storage","t_uint256"]
// .resources.pointers | keys: ["storage-t_array$_t_struct$_Node_$10_storage_$dyn_storage","storage-t_mapping$_t_uint256_$_t_struct$_Leaf_$18_storage_$","storage-t_struct$_Leaf_$18_storage","storage-t_struct$_Node_$10_storage","storage-t_uint256"]
// .resources.pointers.storage-t_array$_t_struct$_Node_$10_storage_$dyn_storage.for.group[1].in.list.is.define.slot: {"~sum":["data",{"~product":["index","0x03"]}]}
// .resources.pointers.storage-t_array$_t_struct$_Node_$10_storage_$dyn_storage.for.group[1].in.list.is.in.template: storage-t_struct$_Node_$10_storage
// .resources.pointers.storage-t_array$_t_struct$_Node_$10_storage_$dyn_storage.for.group[1].in.list.is.in.yields.extra: item-extra
// .resources.pointers.storage-t_array$_t_struct$_Node_$10_storage_$dyn_storage.for.group[1].in.list.is.in.yields.value: item-value
// .resources.pointers.storage-t_mapping$_t_uint256_$_t_struct$_Leaf_$18_storage_$.for.in.template: storage-t_struct$_Leaf_$18_storage
// .resources.pointers.storage-t_mapping$_t_uint256_$_t_struct$_Leaf_$18_storage_$.for.in.yields.byKey: value-byKey
// .resources.pointers.storage-t_mapping$_t_uint256_$_t_struct$_Leaf_$18_storage_$.for.in.yields.value: value-value
// .resources.pointers.storage-t_struct$_Leaf_$18_storage.for.group[1].name: byKey
// .resources.pointers.storage-t_struct$_Leaf_$18_storage.for.group[1].slot: {"~sum":["slot","0x01"]}
// .resources.pointers.storage-t_struct$_Node_$10_storage.for.group[2].define.slot: {"~sum":["slot","0x02"]}
// .resources.pointers.storage-t_struct$_Node_$10_storage.for.group[2].in.template: storage-t_array$_t_struct$_Node_$10_storage_$dyn_storage
// .resources.pointers.storage-t_struct$_Node_$10_storage.for.group[2].in.yields: <PATH NOT FOUND>
