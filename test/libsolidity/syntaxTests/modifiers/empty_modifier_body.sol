abstract contract A { modifier mod(uint a) virtual;}
contract B is A { modifier mod(uint a) override { _; } }

abstract contract C {
	modifier m virtual;
	function f() m public {

	}
}
contract D is C {
	modifier m override {
		_;
	}
}
// ----
// Warning 8429: (22-51): Virtual modifiers are deprecated and scheduled for removal.
// Warning 8429: (134-153): Virtual modifiers are deprecated and scheduled for removal.
