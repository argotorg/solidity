object "t" {
	code {
		sstore(0, eofcreate("name_that_is_longer_than_32_bytes_name_that_is_longer_than_32_bytes_name_that_is_longer_than_32_bytes", 0, 0, 0, 0))
	}
	object "name_that_is_longer_than_32_bytes_name_that_is_longer_than_32_bytes_name_that_is_longer_than_32_bytes" {
		code {}
	}
}
// ====
// bytecodeFormat: >=EOFv1
// optimizationPreset: full
// outputs: Assembly
// ----
// Assembly:
//     /* "source":180:181   */
//   0x00
//     /* "source":56:182   */
//   dup1
//   dup1
//   dup1
//   eofcreate{0}
//     /* "source":53:54   */
//   0x00
//     /* "source":46:183   */
//   sstore
//     /* "source":22:199   */
//   stop
// stop
//
// sub_0: assembly {
//         /* "source":330:337   */
//       stop
// }
