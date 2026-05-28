// Exception for the rule about illegal names.
contract C {
	function this() public {
	}
	function super() public {
	}
	function _() public {
	}
}
// ----
// Warning 6335: (61-88): "this" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (90-118): "super" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 2319: (61-88): This declaration shadows a builtin symbol.
// Warning 2319: (90-118): This declaration shadows a builtin symbol.
