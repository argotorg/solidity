==== Source: A ====
uint constant x = 77;

==== Source: B ====
import "A" as M;
contract C layout at M.x{ }
// ----
// TypeError 1505: (B:38-41): The base slot expression contains elements that are not yet supported by the internal constant evaluator and therefore cannot be evaluated at compilation time.
