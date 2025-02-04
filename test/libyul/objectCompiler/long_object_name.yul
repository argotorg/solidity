object "t" {
	code {
		sstore(0, datasize("name_that_is_longer_than_32_bytes_name_that_is_longer_than_32_bytes_name_that_is_longer_than_32_bytes"))
	}
	object "name_that_is_longer_than_32_bytes_name_that_is_longer_than_32_bytes_name_that_is_longer_than_32_bytes" {
		code {}
	}
}
// ====
// EVMVersion: >=shanghai
// optimizationPreset: full
// outputs: Assembly
// bytecodeFormat: legacy
// ----
// Assembly:
//     /* "source":56:169   */
//   dataSize(sub_0)
//     /* "source":53:54   */
//   0x00
//     /* "source":46:170   */
//   sstore
//     /* "source":22:186   */
//   stop
// stop
//
// sub_0: assembly {
//         /* "source":317:324   */
//       stop
// }
