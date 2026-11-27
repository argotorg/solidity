struct Point { uint8 x; uint8 y; }

contract C {
    uint256[] words;
    uint8[] packed;
    uint256[2][] grid;
    Point[] points;
    string[] texts;
}
// ----
// .resources.types | keys: ["t_array$_t_array$_t_uint256_$2_storage_$dyn_storage","t_array$_t_string_storage_$dyn_storage","t_array$_t_struct$_Point_$6_storage_$dyn_storage","t_array$_t_uint256_$2_storage","t_array$_t_uint256_$dyn_storage","t_array$_t_uint8_$dyn_storage","t_string_storage","t_struct$_Point_$6_storage","t_uint256","t_uint8"]
// .resources.pointers | keys: ["storage-t_array$_t_array$_t_uint256_$2_storage_$dyn_storage","storage-t_array$_t_string_storage_$dyn_storage","storage-t_array$_t_struct$_Point_$6_storage_$dyn_storage","storage-t_array$_t_uint256_$2_storage","storage-t_array$_t_uint256_$dyn_storage","storage-t_array$_t_uint8_$dyn_storage","storage-t_string_storage","storage-t_struct$_Point_$6_storage","storage-t_uint256","storage-t_uint8"]
// .resources.pointers.storage-t_array$_t_array$_t_uint256_$2_storage_$dyn_storage.for.group[1].in.list.is.define.slot: {"~sum":["data",{"~product":["index","0x02"]}]}
// .resources.pointers.storage-t_array$_t_array$_t_uint256_$2_storage_$dyn_storage.for.group[1].in.list.is.in.template: storage-t_array$_t_uint256_$2_storage
// .resources.pointers.storage-t_array$_t_string_storage_$dyn_storage.for.group[1].in.list.is.define.slot: {"~sum":["data","index"]}
// .resources.pointers.storage-t_array$_t_string_storage_$dyn_storage.for.group[1].in.list.is.in.template: storage-t_string_storage
// .resources.pointers.storage-t_array$_t_string_storage_$dyn_storage.for.group[1].in.list.is.in.yields.data: item-data
// .resources.pointers.storage-t_array$_t_struct$_Point_$6_storage_$dyn_storage.for.group[1].in.list.is.define.slot: {"~sum":["data","index"]}
// .resources.pointers.storage-t_array$_t_struct$_Point_$6_storage_$dyn_storage.for.group[1].in.list.is.in.template: storage-t_struct$_Point_$6_storage
// .resources.pointers.storage-t_array$_t_struct$_Point_$6_storage_$dyn_storage.for.group[1].in.list.is.in.yields.x: item-x
// .resources.pointers.storage-t_array$_t_struct$_Point_$6_storage_$dyn_storage.for.group[1].in.list.is.in.yields.y: item-y
// .resources.pointers.storage-t_array$_t_uint256_$2_storage.for.list.count: 0x02
// .resources.pointers.storage-t_array$_t_uint256_$dyn_storage.for.group[0].name: length
// .resources.pointers.storage-t_array$_t_uint256_$dyn_storage.for.group[0].location: storage
// .resources.pointers.storage-t_array$_t_uint256_$dyn_storage.for.group[0].slot: slot
// .resources.pointers.storage-t_array$_t_uint256_$dyn_storage.for.group[1].define.data: {"~keccak256":[{"~wordsized":"slot"}]}
// .resources.pointers.storage-t_array$_t_uint256_$dyn_storage.for.group[1].in.list.count: {"~read":"length"}
// .resources.pointers.storage-t_array$_t_uint256_$dyn_storage.for.group[1].in.list.is.location: storage
// .resources.pointers.storage-t_array$_t_uint256_$dyn_storage.for.group[1].in.list.is.slot: {"~sum":["data","index"]}
// .resources.pointers.storage-t_array$_t_uint8_$dyn_storage.for.group[1].in.list.count: {"~read":"length"}
// .resources.pointers.storage-t_array$_t_uint8_$dyn_storage.for.group[1].in.list.is.length: 0x01
// .resources.pointers.storage-t_array$_t_uint8_$dyn_storage.for.group[1].in.list.is.offset: {"~difference":["~wordsize",{"~sum":[{"~remainder":["index","0x20"]},"0x01"]}]}
// .resources.pointers.storage-t_array$_t_uint8_$dyn_storage.for.group[1].in.list.is.slot: {"~sum":["data",{"~quotient":["index","0x20"]}]}
