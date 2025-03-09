==== Source: A ====
function f() pure {}

==== Source: B ====
import "A" as MyModule;

contract C layout at MyModule {}
// ----
// TypeError 6396: (B:46-54): The base slot of the storage layout must evaluate to a rational number.
