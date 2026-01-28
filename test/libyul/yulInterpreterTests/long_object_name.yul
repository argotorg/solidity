object "t" {
	code {
		datacopy(not(datasize("object2.object3.object4.datablock")), 0, 0)
	}
	object "object2" {
		code{}
		object "object3" {
			code{}
			object "object4" {
				code{}
				data "datablock" ""
			}
		}
	}
}
// ====
// bytecodeFormat: legacy
// ----
// Trace:
// Memory dump:
// Storage dump:
// Transient storage dump:
