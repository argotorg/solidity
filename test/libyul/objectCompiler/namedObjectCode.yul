object "a" {
  code { sstore(0, 1) }
}
// ====
// EVMVersion: >=shanghai
// outputs: Assembly
// ----
// Assembly:
//     /* "source":36:37   */
//   0x01
//     /* "source":33:34   */
//   0x00
//     /* "source":26:38   */
//   sstore
//     /* "source":22:42   */
//   stop
