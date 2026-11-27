contract Base {
    uint256 inherited;
    uint8 packedBase;
}

contract C is Base {
    uint8 packedOwn;
    uint256 own;
    uint256 constant CONSTANT = 1;
    uint256 immutable IMMUTABLE = 2;
}

contract D is Base {
    string own;
}
// ----
// .resources.types | keys: ["t_string_storage","t_uint256","t_uint8"]
// .resources.pointers | keys: ["storage-t_string_storage","storage-t_uint256","storage-t_uint8"]
