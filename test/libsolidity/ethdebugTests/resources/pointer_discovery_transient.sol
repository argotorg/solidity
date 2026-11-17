contract C {
    uint256 transient word;
    uint8 transient a;
    bool transient b;
    address transient c;
    uint256 stored;
}
// ====
// EVMVersion: >=cancun
// ----
// .resources.types | keys: ["t_address","t_bool","t_uint256","t_uint8"]
// .resources.pointers | keys: ["storage-t_uint256","transient-t_address","transient-t_bool","transient-t_uint256","transient-t_uint8"]
