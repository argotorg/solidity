contract A layout at 3/2 {}
contract B layout at 4.2 {}
contract C layout at .1 {}
contract D layout at 42e-10 {}
contract E layout at 1_7e-10 {}
// ----
// TypeError 1763: (21-24): The base slot of the storage layout must evaluate to an integer.
// TypeError 1763: (49-52): The base slot of the storage layout must evaluate to an integer.
// TypeError 1763: (77-79): The base slot of the storage layout must evaluate to an integer.
// TypeError 1763: (104-110): The base slot of the storage layout must evaluate to an integer.
// TypeError 1763: (135-142): The base slot of the storage layout must evaluate to an integer.
