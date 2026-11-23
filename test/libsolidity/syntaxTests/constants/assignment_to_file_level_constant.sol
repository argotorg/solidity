==== Source: a ====
uint constant F = 1;
==== Source: b ====
import "a" as M;
import {F} from "a";
function f() {
    F = 2;
    M.F = 2;
}
// ----
// TypeError 6520: (b:57-58): Cannot assign to a constant variable.
// TypeError 4247: (b:68-71): Expression has to be an lvalue.
