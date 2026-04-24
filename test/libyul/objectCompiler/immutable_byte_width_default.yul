object "a" {
    code {
        let size := datasize("runtime")
        datacopy(0, dataoffset("runtime"), size)
        setimmutable(0, "val", 0x42)
        return(0, size)
    }
    object "runtime" {
        code {
            sstore(0, loadimmutable("val"))
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
//     /* "source":166:170   */
//   0x42
//     /* "source":156:157   */
//   0x00
//     /* "source":143:171   */
//   assignImmutable("0x749eb9a32604a1e3d5563e475f22a54221a22999f274fb5acd84a00d16053a11")
//     /* "source":191:192   */
//   0x00
//     /* "source":184:199   */
//   return
// stop
//
// sub_0: assembly {
//         /* "source":294:314   */
//       immutable("0x749eb9a32604a1e3d5563e475f22a54221a22999f274fb5acd84a00d16053a11")
//         /* "source":291:292   */
//       0x00
//         /* "source":284:315   */
//       sstore
//         /* "source":252:339   */
//       stop
// }
