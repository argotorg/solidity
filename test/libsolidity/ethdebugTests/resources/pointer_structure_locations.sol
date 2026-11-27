type Price is uint64;
enum Color { Red, Green }
struct Point { uint8 x; int16 y; }
struct Record { Point point; uint16[] values; string text; bytes4 tag; }
contract C {
    Record stored;
    uint16 transient temporary;
    Price price;
    Color color;
    function () external callback;
    function () internal internalCallback;
    function inspect(Record calldata input, uint16[2][3] calldata fixedValues, bytes[][2] calldata blobs)
        external pure returns (Record memory result)
    {
        result = input;
        uint16[2][3] memory fixedCopy = fixedValues;
        bytes[][2] memory blobCopy = blobs;
        fixedCopy; blobCopy;
    }
}
// ====
// EVMVersion: >=cancun
// ----
// .resources.pointers | keys: ["calldata-t_array$_t_array$_t_bytes_storage_$dyn_storage_$2_storage","calldata-t_array$_t_array$_t_uint16_$2_storage_$3_storage","calldata-t_array$_t_bytes_storage_$dyn_storage","calldata-t_array$_t_uint16_$2_storage","calldata-t_array$_t_uint16_$dyn_storage","calldata-t_bytes4","calldata-t_bytes_storage","calldata-t_int16","calldata-t_string_storage","calldata-t_struct$_Point_$11_storage","calldata-t_struct$_Record_$22_storage","calldata-t_uint16","calldata-t_uint8","memory-t_array$_t_array$_t_bytes_storage_$dyn_storage_$2_storage","memory-t_array$_t_array$_t_uint16_$2_storage_$3_storage","memory-t_array$_t_bytes_storage_$dyn_storage","memory-t_array$_t_uint16_$2_storage","memory-t_array$_t_uint16_$dyn_storage","memory-t_bytes4","memory-t_bytes_storage","memory-t_int16","memory-t_string_storage","memory-t_struct$_Point_$11_storage","memory-t_struct$_Record_$22_storage","memory-t_uint16","memory-t_uint8","storage-t_array$_t_uint16_$dyn_storage","storage-t_bytes4","storage-t_enum$_Color_$6","storage-t_function_external_nonpayable$__$returns$__$","storage-t_function_internal_nonpayable$__$returns$__$","storage-t_int16","storage-t_string_storage","storage-t_struct$_Point_$11_storage","storage-t_struct$_Record_$22_storage","storage-t_uint16","storage-t_uint8","storage-t_userDefinedValueType$_Price_$3","transient-t_uint16"]
// .resources.pointers.memory-t_struct$_Record_$22_storage.for.group[0].group[0].location: memory
// .resources.pointers.memory-t_struct$_Record_$22_storage.for.group[0].group[1].define.offset: {"~read":"point-address"}
// .resources.pointers.memory-t_struct$_Record_$22_storage.for.group[0].group[1].in.template: memory-t_struct$_Point_$11_storage
// .resources.pointers.memory-t_struct$_Record_$22_storage.for.group[1].group[0].offset: {"~sum":["offset","0x20"]}
// .resources.pointers.memory-t_struct$_Record_$22_storage.for.group[1].group[1].define.offset: {"~read":"values-address"}
// .resources.pointers.memory-t_struct$_Record_$22_storage.for.group[2].group[0].offset: {"~sum":["offset","0x40"]}
// .resources.pointers.memory-t_struct$_Record_$22_storage.for.group[2].group[1].define.offset: {"~read":"text-address"}
// .resources.pointers.memory-t_struct$_Record_$22_storage.for.group[3].offset: {"~sum":["offset","0x60"]}
// .resources.pointers.calldata-t_struct$_Record_$22_storage.for.group[0].define.offset: offset
// .resources.pointers.calldata-t_struct$_Record_$22_storage.for.group[0].in.template: calldata-t_struct$_Point_$11_storage
// .resources.pointers.calldata-t_struct$_Record_$22_storage.for.group[1].group[0].location: calldata
// .resources.pointers.calldata-t_struct$_Record_$22_storage.for.group[1].group[0].offset: {"~sum":["offset","0x40"]}
// .resources.pointers.calldata-t_struct$_Record_$22_storage.for.group[1].group[1].define.offset: {"~sum":["offset",{"~read":"values-address"}]}
// .resources.pointers.calldata-t_struct$_Record_$22_storage.for.group[2].group[0].offset: {"~sum":["offset","0x60"]}
// .resources.pointers.calldata-t_struct$_Record_$22_storage.for.group[2].group[1].define.offset: {"~sum":["offset",{"~read":"text-address"}]}
// .resources.pointers.calldata-t_struct$_Record_$22_storage.for.group[3].offset: {"~sum":["offset","0x80"]}
// .resources.pointers.memory-t_array$_t_array$_t_uint16_$2_storage_$3_storage.for.group[0].in.list.count: 0x03
// .resources.pointers.memory-t_array$_t_array$_t_uint16_$2_storage_$3_storage.for.group[0].in.list.is.group[0].offset: {"~sum":["data",{"~product":["index","0x20"]}]}
// .resources.pointers.memory-t_array$_t_array$_t_uint16_$2_storage_$3_storage.for.group[0].in.list.is.group[1].define.offset: {"~read":"item-address"}
// .resources.pointers.memory-t_array$_t_array$_t_uint16_$2_storage_$3_storage.for.group[0].in.list.is.group[1].in.template: memory-t_array$_t_uint16_$2_storage
// .resources.pointers.calldata-t_array$_t_array$_t_uint16_$2_storage_$3_storage.for.group[0].in.list.count: 0x03
// .resources.pointers.calldata-t_array$_t_array$_t_uint16_$2_storage_$3_storage.for.group[0].in.list.is.define.offset: {"~sum":["data",{"~product":["index","0x40"]}]}
// .resources.pointers.calldata-t_array$_t_array$_t_uint16_$2_storage_$3_storage.for.group[0].in.list.is.in.template: calldata-t_array$_t_uint16_$2_storage
// .resources.pointers.memory-t_array$_t_array$_t_bytes_storage_$dyn_storage_$2_storage.for.group[0].in.list.count: 0x02
// .resources.pointers.memory-t_array$_t_array$_t_bytes_storage_$dyn_storage_$2_storage.for.group[0].in.list.is.group[1].define.offset: {"~read":"item-address"}
// .resources.pointers.memory-t_array$_t_array$_t_bytes_storage_$dyn_storage_$2_storage.for.group[0].in.list.is.group[1].in.template: memory-t_array$_t_bytes_storage_$dyn_storage
// .resources.pointers.calldata-t_array$_t_array$_t_bytes_storage_$dyn_storage_$2_storage.for.group[0].in.list.count: 0x02
// .resources.pointers.calldata-t_array$_t_array$_t_bytes_storage_$dyn_storage_$2_storage.for.group[0].in.list.is.group[0].offset: {"~sum":["data",{"~product":["index","0x20"]}]}
// .resources.pointers.calldata-t_array$_t_array$_t_bytes_storage_$dyn_storage_$2_storage.for.group[0].in.list.is.group[1].define.offset: {"~sum":["data",{"~read":"item-address"}]}
// .resources.pointers.calldata-t_array$_t_array$_t_bytes_storage_$dyn_storage_$2_storage.for.group[0].in.list.is.group[1].in.template: calldata-t_array$_t_bytes_storage_$dyn_storage
// .resources.pointers.memory-t_bytes4.for.location: memory
// .resources.pointers.memory-t_bytes4.for.length: 0x04
// .resources.pointers.memory-t_bytes4.for.offset: offset
// .resources.pointers.transient-t_uint16.for.location: transient
// .resources.pointers.transient-t_uint16.for.length: 0x02
// .resources.pointers.transient-t_uint16.for.offset: {"~difference":["0x1e","offset"]}
// .resources.pointers.transient-t_uint16.for.slot: slot
