struct Point { uint8 x; uint8 y; }
struct Wide { uint256 a; uint128 b; uint256 c; }

contract C {
    uint16[8] packed;
    uint256[3] words;
    uint128[3] halves;
    bytes32[2][2] grid;
    Point[2] points;
    Wide[2] wides;
}
// ----
// .resources.types | keys: ["t_array$_t_array$_t_bytes32_$2_storage_$2_storage","t_array$_t_bytes32_$2_storage","t_array$_t_struct$_Point_$6_storage_$2_storage","t_array$_t_struct$_Wide_$13_storage_$2_storage","t_array$_t_uint128_$3_storage","t_array$_t_uint16_$8_storage","t_array$_t_uint256_$3_storage","t_bytes32","t_struct$_Point_$6_storage","t_struct$_Wide_$13_storage","t_uint128","t_uint16","t_uint256","t_uint8"]
// .resources.pointers | keys: ["storage-t_array$_t_array$_t_bytes32_$2_storage_$2_storage","storage-t_array$_t_bytes32_$2_storage","storage-t_array$_t_struct$_Point_$6_storage_$2_storage","storage-t_array$_t_struct$_Wide_$13_storage_$2_storage","storage-t_array$_t_uint128_$3_storage","storage-t_array$_t_uint16_$8_storage","storage-t_array$_t_uint256_$3_storage","storage-t_bytes32","storage-t_struct$_Point_$6_storage","storage-t_struct$_Wide_$13_storage","storage-t_uint128","storage-t_uint16","storage-t_uint256","storage-t_uint8"]
// .resources.pointers.storage-t_array$_t_array$_t_bytes32_$2_storage_$2_storage.for.list.count: 0x02
// .resources.pointers.storage-t_array$_t_array$_t_bytes32_$2_storage_$2_storage.for.list.is.define.slot: {"~sum":["slot",{"~product":["index","0x02"]}]}
// .resources.pointers.storage-t_array$_t_array$_t_bytes32_$2_storage_$2_storage.for.list.is.in.template: storage-t_array$_t_bytes32_$2_storage
// .resources.pointers.storage-t_array$_t_bytes32_$2_storage.for.list.count: 0x02
// .resources.pointers.storage-t_array$_t_bytes32_$2_storage.for.list.is.slot: {"~sum":["slot","index"]}
// .resources.pointers.storage-t_array$_t_struct$_Point_$6_storage_$2_storage.for.list.count: 0x02
// .resources.pointers.storage-t_array$_t_struct$_Point_$6_storage_$2_storage.for.list.is.define.slot: {"~sum":["slot","index"]}
// .resources.pointers.storage-t_array$_t_struct$_Point_$6_storage_$2_storage.for.list.is.in.template: storage-t_struct$_Point_$6_storage
// .resources.pointers.storage-t_array$_t_struct$_Wide_$13_storage_$2_storage.for.list.count: 0x02
// .resources.pointers.storage-t_array$_t_struct$_Wide_$13_storage_$2_storage.for.list.is.define.slot: {"~sum":["slot",{"~product":["index","0x03"]}]}
// .resources.pointers.storage-t_array$_t_struct$_Wide_$13_storage_$2_storage.for.list.is.in.template: storage-t_struct$_Wide_$13_storage
// .resources.pointers.storage-t_array$_t_struct$_Wide_$13_storage_$2_storage.for.list.is.in.yields | keys: ["a","b","c"]
// .resources.pointers.storage-t_array$_t_uint128_$3_storage.for.list.count: 0x03
// .resources.pointers.storage-t_array$_t_uint128_$3_storage.for.list.is.length: 0x10
// .resources.pointers.storage-t_array$_t_uint128_$3_storage.for.list.is.offset: {"~difference":["~wordsize",{"~product":[{"~sum":[{"~remainder":["index","0x02"]},"0x01"]},"0x10"]}]}
// .resources.pointers.storage-t_array$_t_uint128_$3_storage.for.list.is.slot: {"~sum":["slot",{"~quotient":["index","0x02"]}]}
// .resources.pointers.storage-t_array$_t_uint16_$8_storage.for.list.count: 0x08
// .resources.pointers.storage-t_array$_t_uint16_$8_storage.for.list.is.length: 0x02
// .resources.pointers.storage-t_array$_t_uint16_$8_storage.for.list.is.offset: {"~difference":["~wordsize",{"~product":[{"~sum":[{"~remainder":["index","0x10"]},"0x01"]},"0x02"]}]}
// .resources.pointers.storage-t_array$_t_uint16_$8_storage.for.list.is.slot: {"~sum":["slot",{"~quotient":["index","0x10"]}]}
// .resources.pointers.storage-t_array$_t_uint256_$3_storage.for.list.count: 0x03
// .resources.pointers.storage-t_array$_t_uint256_$3_storage.for.list.is.slot: {"~sum":["slot","index"]}
// .resources.pointers.storage-t_struct$_Wide_$13_storage.for.group | length: 3
// .resources.pointers.storage-t_struct$_Wide_$13_storage.for.group[0].slot: slot
// .resources.pointers.storage-t_struct$_Wide_$13_storage.for.group[1].slot: {"~sum":["slot","0x01"]}
// .resources.pointers.storage-t_struct$_Wide_$13_storage.for.group[1].offset: 0x10
// .resources.pointers.storage-t_struct$_Wide_$13_storage.for.group[1].length: 0x10
// .resources.pointers.storage-t_struct$_Wide_$13_storage.for.group[2].slot: {"~sum":["slot","0x02"]}
