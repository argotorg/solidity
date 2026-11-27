struct Packed {
    uint8 a;
    uint16 b;
    bool c;
    address d;
    uint256 e;
    bytes32 f;
    uint128 g;
    uint128 h;
    uint64 i;
}

contract C {
    Packed packed;
}
// ----
// .resources.types | keys: ["t_address","t_bool","t_bytes32","t_struct$_Packed_$20_storage","t_uint128","t_uint16","t_uint256","t_uint64","t_uint8"]
// .resources.pointers | keys: ["storage-t_address","storage-t_bool","storage-t_bytes32","storage-t_struct$_Packed_$20_storage","storage-t_uint128","storage-t_uint16","storage-t_uint256","storage-t_uint64","storage-t_uint8"]
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group | length: 9
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[0].name: a
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[0].slot: slot
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[0].offset: 0x1f
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[0].length: 0x01
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[1].name: b
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[1].slot: slot
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[1].offset: 0x1d
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[1].length: 0x02
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[2].name: c
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[2].slot: slot
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[2].offset: 0x1c
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[2].length: 0x01
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[3].name: d
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[3].slot: slot
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[3].offset: 0x08
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[3].length: 0x14
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[4].name: e
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[4].slot: {"~sum":["slot","0x01"]}
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[4].offset: <PATH NOT FOUND>
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[4].length: <PATH NOT FOUND>
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[5].name: f
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[5].slot: {"~sum":["slot","0x02"]}
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[5].offset: <PATH NOT FOUND>
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[5].length: <PATH NOT FOUND>
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[6].name: g
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[6].slot: {"~sum":["slot","0x03"]}
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[6].offset: 0x10
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[6].length: 0x10
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[7].name: h
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[7].slot: {"~sum":["slot","0x03"]}
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[7].offset: <PATH NOT FOUND>
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[7].length: 0x10
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[8].name: i
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[8].slot: {"~sum":["slot","0x04"]}
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[8].offset: 0x18
// .resources.pointers.storage-t_struct$_Packed_$20_storage.for.group[8].length: 0x08
// .resources.pointers.storage-t_uint128.for.offset: {"~difference":["0x10","offset"]}
// .resources.pointers.storage-t_uint128.for.length: 0x10
// .resources.pointers.storage-t_uint256.for.offset: {"~difference":["0x00","offset"]}
// .resources.pointers.storage-t_uint256.for.length: 0x20
