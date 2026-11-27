type $Amount is uint128;
enum $Choice { First, Second }
struct $Record { uint256 $member; $Amount $amount; $Choice $choice; }

contract $C {
    uint256 $value;
    $Record $struct;
    $Record[] $items;
    $C $self;
}
// ----
// .resources.types | keys: ["t_array$_t_struct$_$$$Record_$15_storage_$dyn_storage","t_contract$_$$$C_$28","t_enum$_$$$Choice_$6","t_struct$_$$$Record_$15_storage","t_uint128","t_uint256","t_userDefinedValueType$_$$$Amount_$3"]
// .resources.pointers | keys: ["storage-t_array$_t_struct$_$$$Record_$15_storage_$dyn_storage","storage-t_contract$_$$$C_$28","storage-t_enum$_$$$Choice_$6","storage-t_struct$_$$$Record_$15_storage","storage-t_uint256","storage-t_userDefinedValueType$_$$$Amount_$3"]
// .resources.types.t_contract$_$$$C_$28.definition.name: $C
// .resources.types.t_enum$_$$$Choice_$6.definition.name: $Choice
// .resources.types.t_struct$_$$$Record_$15_storage.definition.name: $Record
// .resources.types.t_userDefinedValueType$_$$$Amount_$3.definition.name: $Amount
// .resources.pointers.storage-t_array$_t_struct$_$$$Record_$15_storage_$dyn_storage.for.group[1].in.list.is.define.slot: {"~sum":["data",{"~product":["index","0x02"]}]}
// .resources.pointers.storage-t_array$_t_struct$_$$$Record_$15_storage_$dyn_storage.for.group[1].in.list.is.in.template: storage-t_struct$_$$$Record_$15_storage
// .resources.pointers.storage-t_array$_t_struct$_$$$Record_$15_storage_$dyn_storage.for.group[1].in.list.is.in.yields.$amount: item-$amount
// .resources.pointers.storage-t_array$_t_struct$_$$$Record_$15_storage_$dyn_storage.for.group[1].in.list.is.in.yields.$choice: item-$choice
// .resources.pointers.storage-t_array$_t_struct$_$$$Record_$15_storage_$dyn_storage.for.group[1].in.list.is.in.yields.$member: item-$member
// .resources.pointers.storage-t_struct$_$$$Record_$15_storage.for.group | length: 3
// .resources.pointers.storage-t_struct$_$$$Record_$15_storage.for.group[0].name: $member
// .resources.pointers.storage-t_struct$_$$$Record_$15_storage.for.group[1].name: $amount
// .resources.pointers.storage-t_struct$_$$$Record_$15_storage.for.group[2].name: $choice
