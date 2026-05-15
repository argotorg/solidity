==== Source: A.sol ====
==== Source: B.sol ====
import * as A from "A.sol";
contract BContract {}
enum Enum { VAL }
struct S { uint256 v; }
type UInt is uint256;
error Err();
event Ev();
function foo() {}
==== Source: C.sol ====
import * as B from "B.sol";

contract C {
    function () constant fooConstPtr = B.foo;

    function test() pure private {
       B.BContract;
       B.Enum;
       B.S;
       B.UInt;
       B.Err;
       B.Ev;
       B.foo;
       B.A;
    }
}
// ----
// Warning 6133: (C.sol:131-142): Statement has no effect.
// Warning 6133: (C.sol:151-157): Statement has no effect.
// Warning 6133: (C.sol:166-169): Statement has no effect.
// Warning 6133: (C.sol:178-184): Statement has no effect.
// Warning 6133: (C.sol:193-198): Statement has no effect.
// Warning 6133: (C.sol:207-211): Statement has no effect.
// Warning 6133: (C.sol:220-225): Statement has no effect.
// Warning 6133: (C.sol:234-237): Statement has no effect.
