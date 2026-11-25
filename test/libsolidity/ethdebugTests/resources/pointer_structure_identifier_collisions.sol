struct $ { uint8 $; uint8 _$_; }
struct _$_ { $ a; $ b; }

contract C {
    $ first;
    _$_ second;
}
// ----
// .resources.types | keys: ["t_struct$_$$$_$6_storage","t_struct$__$$$__$13_storage","t_uint8"]
// .resources.pointers | keys: ["storage-t_struct$_$$$_$6_storage","storage-t_struct$__$$$__$13_storage","storage-t_uint8"]
// .resources.types.t_struct$_$$$_$6_storage.definition.name: $
// .resources.types.t_struct$__$$$__$13_storage.definition.name: _$_
// .resources.pointers.storage-t_struct$_$$$_$6_storage.for.group | length: 2
// .resources.pointers.storage-t_struct$_$$$_$6_storage.for.group[0].name: $
// .resources.pointers.storage-t_struct$_$$$_$6_storage.for.group[1].name: _$_
// .resources.pointers.storage-t_struct$__$$$__$13_storage.for.group[0].template: storage-t_struct$_$$$_$6_storage
// .resources.pointers.storage-t_struct$__$$$__$13_storage.for.group[0].yields.$: a-$
// .resources.pointers.storage-t_struct$__$$$__$13_storage.for.group[0].yields._$_: a-_$_
// .resources.pointers.storage-t_struct$__$$$__$13_storage.for.group[1].in.template: storage-t_struct$_$$$_$6_storage
// .resources.pointers.storage-t_struct$__$$$__$13_storage.for.group[1].in.yields.$: b-$
// .resources.pointers.storage-t_struct$__$$$__$13_storage.for.group[1].in.yields._$_: b-_$_
