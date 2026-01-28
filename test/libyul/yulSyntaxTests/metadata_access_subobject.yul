object "A" {
	code {
		sstore(dataoffset(".metadata.x"), 0)
	}

	object ".metadata" {
		code {}
		data "x" "ABC"
	}
}
// ====
// bytecodeFormat: legacy
// ----
// TypeError 3517: (41-54): Unknown data object ".metadata.x".
