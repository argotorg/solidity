contract A {
	function f() mod internal returns (uint[] storage) {
		revert();
	}
	function g() mod internal returns (uint[] storage) {
	}
	modifier mod() virtual {
		_;
	}
}
// ----
// Warning 8429: (140-172): Virtual modifiers are deprecated and scheduled for removal.
// TypeError 3464: (118-132): This variable is of storage pointer type and can be returned without prior assignment, which would lead to undefined behaviour.
