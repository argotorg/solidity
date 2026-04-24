object "a" {
    code {
        let size := datasize("runtime")
        datacopy(0, dataoffset("runtime"), size)
        setimmutable(0, "val@1", 0x42)
        return(0, size)
    }
    object "runtime" {
        code {
            sstore(0, loadimmutable("val@1"))
        }
    }
}
// ====
// EVMVersion: >=shanghai
// bytecodeFormat: legacy
// outputs: Assembly
// ----
// Assembly:
//     /* "source":58:77   */
//   dataSize(sub_0)
//     /* "source":102:123   */
//   dup1
//   dataOffset(sub_0)
//     /* "source":99:100   */
//   0x00
//     /* "source":90:130   */
//   codecopy
//     /* "source":168:172   */
//   0x42
//     /* "source":156:157   */
//   0x00
//     /* "source":143:173   */
//   assignImmutable("0x749eb9a32604a1e3d5563e475f22a54221a22999f274fb5acd84a00d16053a11")
//     /* "source":193:194   */
//   0x00
//     /* "source":186:201   */
//   return
// stop
//
// sub_0: assembly {
//         /* "source":296:318   */
//       immutable("0x749eb9a32604a1e3d5563e475f22a54221a22999f274fb5acd84a00d16053a11")
//         /* "source":293:294   */
//       0x00
//         /* "source":286:319   */
//       sstore
//         /* "source":254:343   */
//       stop
// }
