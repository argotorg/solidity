contract C {
	function f() pure public {
		assembly {
			pop(pc())
		}
	}
}
// ====
// bytecodeFormat: legacy
// ----
// SyntaxError 2450: (61-63): PC instruction is a low-level EVM feature. Because of that PC is disallowed in strict assembly.
