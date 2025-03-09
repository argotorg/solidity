contract A layout at this {}
contract B layout at super {}
contract C layout at msg {}
contract D layout at tx {}
contract E layout at block {}
// ----
// TypeError 1139: (21-25): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (50-55): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (80-83): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (108-110): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (135-140): The base slot of the storage layout must be a compile-time constant expression.
