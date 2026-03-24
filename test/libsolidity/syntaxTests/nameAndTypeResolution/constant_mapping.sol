contract C {
    mapping(uint => uint) constant x;
}
// ----
// TypeError 9259: (17-49): Constants of this type are not supported. Only value types, arrays, structs, and byte/string types without mappings are allowed.
