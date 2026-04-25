contract C {
    struct S {
        mapping(uint => uint) x;
    }
    S public constant c;
}
// ----
// TypeError 9259: (71-90): Constants of this type are not supported. Only value types, arrays, structs, and byte/string types without mappings are allowed.
