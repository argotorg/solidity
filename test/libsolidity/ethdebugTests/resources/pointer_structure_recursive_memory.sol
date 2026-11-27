struct Node { uint256 value; Node[] children; }
contract C {
    function f() external pure {
        Node memory node;
        node.children;
    }
}
// ----
// .resources.types | keys: ["t_array$_t_struct$_Node_$8_storage_$dyn_storage","t_struct$_Node_$8_storage","t_tuple$__$","t_uint256"]
// .resources.pointers | keys: ["memory-t_array$_t_struct$_Node_$8_storage_$dyn_storage","memory-t_struct$_Node_$8_storage","memory-t_uint256"]
// .resources.pointers.memory-t_struct$_Node_$8_storage.for.group[1].group[0].offset: {"~sum":["offset","0x20"]}
// .resources.pointers.memory-t_struct$_Node_$8_storage.for.group[1].group[1].define.offset: {"~read":"children-address"}
// .resources.pointers.memory-t_struct$_Node_$8_storage.for.group[1].group[1].in.template: memory-t_array$_t_struct$_Node_$8_storage_$dyn_storage
// .resources.pointers.memory-t_struct$_Node_$8_storage.for.group[1].group[1].in.yields: <PATH NOT FOUND>
// .resources.pointers.memory-t_array$_t_struct$_Node_$8_storage_$dyn_storage.for.group[1].define.data: {"~sum":["offset","0x20"]}
// .resources.pointers.memory-t_array$_t_struct$_Node_$8_storage_$dyn_storage.for.group[1].in.list.count: {"~read":"length"}
// .resources.pointers.memory-t_array$_t_struct$_Node_$8_storage_$dyn_storage.for.group[1].in.list.is.group[1].define.offset: {"~read":"item-address"}
// .resources.pointers.memory-t_array$_t_struct$_Node_$8_storage_$dyn_storage.for.group[1].in.list.is.group[1].in.template: memory-t_struct$_Node_$8_storage
// .resources.pointers.memory-t_array$_t_struct$_Node_$8_storage_$dyn_storage.for.group[1].in.list.is.group[1].in.yields.children-address: item-children-address
