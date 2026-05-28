contract C {
	/// @return foo
	event E(uint x);
}
// ----
// DocstringParsingError 6546: (14-29): Documentation tag @return not valid for events.
