==== Source: a ====
contract A {}
==== Source: b ====
import {A as layout} from "a";
contract C is layout {}
// ----
// Warning 6335: (b:13-19): "layout" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
