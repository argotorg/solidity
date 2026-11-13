{
	for { for {} 1 {} { function f() {} } } 1 {} {}
}
// ----
// SyntaxError 3441: (23-31): Functions cannot be defined inside a for-loop init block.
