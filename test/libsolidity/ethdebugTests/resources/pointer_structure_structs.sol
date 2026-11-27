struct Point { uint8 x; uint8 y; bytes4 salt; }
struct Line { Point from; Point to; string label; }
struct Registry { uint256 count; mapping(address => uint256) index; }

contract C {
    Point point;
    Line line;
    Registry registry;
}
// ----
// .resources.types | keys: ["t_address","t_bytes4","t_mapping$_t_address_$_t_uint256_$","t_string_storage","t_struct$_Line_$17_storage","t_struct$_Point_$8_storage","t_struct$_Registry_$24_storage","t_uint256","t_uint8"]
// .resources.pointers | keys: ["storage-t_bytes4","storage-t_mapping$_t_address_$_t_uint256_$","storage-t_string_storage","storage-t_struct$_Line_$17_storage","storage-t_struct$_Point_$8_storage","storage-t_struct$_Registry_$24_storage","storage-t_uint256","storage-t_uint8"]
// .resources.pointers.storage-t_struct$_Line_$17_storage.for.group | length: 3
// .resources.pointers.storage-t_struct$_Line_$17_storage.for.group[0].template: storage-t_struct$_Point_$8_storage
// .resources.pointers.storage-t_struct$_Line_$17_storage.for.group[0].yields.x: from-x
// .resources.pointers.storage-t_struct$_Line_$17_storage.for.group[0].yields.salt: from-salt
// .resources.pointers.storage-t_struct$_Line_$17_storage.for.group[1].define.slot: {"~sum":["slot","0x01"]}
// .resources.pointers.storage-t_struct$_Line_$17_storage.for.group[1].in.template: storage-t_struct$_Point_$8_storage
// .resources.pointers.storage-t_struct$_Line_$17_storage.for.group[1].in.yields.x: to-x
// .resources.pointers.storage-t_struct$_Line_$17_storage.for.group[2].define.slot: {"~sum":["slot","0x02"]}
// .resources.pointers.storage-t_struct$_Line_$17_storage.for.group[2].in.template: storage-t_string_storage
// .resources.pointers.storage-t_struct$_Line_$17_storage.for.group[2].in.yields.data: label-data
// .resources.pointers.storage-t_struct$_Point_$8_storage.for.group | length: 3
// .resources.pointers.storage-t_struct$_Point_$8_storage.for.group[0].offset: 0x1f
// .resources.pointers.storage-t_struct$_Point_$8_storage.for.group[1].offset: 0x1e
// .resources.pointers.storage-t_struct$_Point_$8_storage.for.group[2].offset: 0x1a
// .resources.pointers.storage-t_struct$_Point_$8_storage.for.group[2].length: 0x04
// .resources.pointers.storage-t_struct$_Registry_$24_storage.for.group[0].name: count
// .resources.pointers.storage-t_struct$_Registry_$24_storage.for.group[0].slot: slot
// .resources.pointers.storage-t_struct$_Registry_$24_storage.for.group[1].name: index
// .resources.pointers.storage-t_struct$_Registry_$24_storage.for.group[1].slot: {"~sum":["slot","0x01"]}
