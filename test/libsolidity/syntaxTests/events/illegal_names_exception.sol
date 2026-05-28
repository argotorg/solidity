// Exception for the illegal name list. External interface events
contract C {
	event this();
	event super();
	event _();
}
// ----
// Warning 6335: (80-93): "this" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (95-109): "super" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 2319: (80-93): This declaration shadows a builtin symbol.
// Warning 2319: (95-109): This declaration shadows a builtin symbol.
