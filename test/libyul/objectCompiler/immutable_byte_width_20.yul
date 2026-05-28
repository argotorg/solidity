object "a" {
    code {
        let size := datasize("runtime")
        datacopy(0, dataoffset("runtime"), size)
        setimmutable(0, "addr@20", 0xdead)
        return(0, size)
    }
    object "runtime" {
        code {
            sstore(0, loadimmutable("addr@20"))
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
//     /* "source":170:176   */
//   0xdead
//     /* "source":156:157   */
//   0x00
//     /* "source":143:177   */
//   assignImmutable("0xe5e14487b78f85faa6e1808e89246cf57dd34831548ff2e6097380d98db2504a")
//     /* "source":197:198   */
//   0x00
//     /* "source":190:205   */
//   return
// stop
//
// sub_0: assembly {
//         /* "source":300:324   */
//       immutable("0xe5e14487b78f85faa6e1808e89246cf57dd34831548ff2e6097380d98db2504a")
//         /* "source":297:298   */
//       0x00
//         /* "source":290:325   */
//       sstore
//         /* "source":258:349   */
//       stop
// }
