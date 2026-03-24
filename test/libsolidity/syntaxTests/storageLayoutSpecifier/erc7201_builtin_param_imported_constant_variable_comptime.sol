==== Source: A ====
string constant storageBase = "myStorageBase";
==== Source: B ====
import "A";
contract C layout at erc7201(storageBase) {}
// ----
