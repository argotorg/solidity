interface I {
	event E(uint x);
}
contract C is I {
	/// @return bar
	event E(uint x);
}
// ----
// DocstringParsingError 6546: (53-68): Documentation tag @return not valid for events.
// DeclarationError 5883: (70-86): Event with same name and parameter types defined twice.
