interface I {}

contract C {
    uint8 small;
    bool flag;
    int256 signed;
    address owner;
    address payable sink;
    bytes32 hash;
    bytes blob;
    string text;
    C self;
    I other;
    function f(uint16 a, bytes4 b) public pure returns (bool) { return a > 0 && b != 0; }
}
// ----
// .resources.types | keys: ["t_address","t_address_payable","t_bool","t_bytes32","t_bytes4","t_bytes_storage","t_contract$_C_$43","t_contract$_I_$2","t_int256","t_string_storage","t_tuple$_t_bool_$","t_tuple$_t_uint16_$_t_bytes4_$","t_uint16","t_uint8"]
// .resources.pointers | keys: ["storage-t_address","storage-t_address_payable","storage-t_bool","storage-t_bytes32","storage-t_bytes_storage","storage-t_contract$_C_$43","storage-t_contract$_I_$2","storage-t_int256","storage-t_string_storage","storage-t_uint8"]
// .resources.types.t_address.payable: false
// .resources.types.t_address_payable.payable: true
// .resources.types.t_bool.kind: bool
// .resources.types.t_bytes32.size: 32
// .resources.types.t_bytes4.size: 4
// .resources.types.t_bytes_storage.kind: bytes
// .resources.types.t_bytes_storage.size: <PATH NOT FOUND>
// .resources.types.t_contract$_C_$43.definition.name: C
// .resources.types.t_contract$_C_$43.interface: <PATH NOT FOUND>
// .resources.types.t_contract$_I_$2.definition.name: I
// .resources.types.t_contract$_I_$2.interface: true
// .resources.types.t_int256.kind: int
// .resources.types.t_int256.bits: 256
// .resources.types.t_string_storage.kind: string
// .resources.types.t_uint16.bits: 16
// .resources.types.t_uint8.bits: 8
