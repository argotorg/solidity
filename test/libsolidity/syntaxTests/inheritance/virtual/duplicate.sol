contract C
{
	function foo() virtual public virtual {}
}
// ----
// ParserError 6879: (44-51): Virtual already specified.
