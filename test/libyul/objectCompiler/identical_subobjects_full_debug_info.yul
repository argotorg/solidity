// All objects have identical unoptimized code, but with different debug annotations.
// The optimized Yul will be identical only between objects that have identical debug info.

/// @use-src 0:"A.sol"
object "A" {
    code {
        function load(i) -> r { r := calldataload(i) }
        /// @src 0:10:20
        sstore(load(0), load(1))
    }

    /// @use-src 0:"B.sol"
    object "B" {
        code {
            function load(i) -> r { r := calldataload(i) }
            /// @src 0:10:20
            sstore(load(0), load(1))
        }

        /// @use-src 0:"A.sol"
        object "A" {
            code {
                function load(i) -> r { r := calldataload(i) }
                /// @src 0:10:20
                sstore(load(0), load(1))
            }

            /// @use-src 0:"B.sol"
            object "B" {
                code {
                    function load(i) -> r { r := calldataload(i) }
                    /// @src 0:10:20
                    sstore(load(0), load(1))
                }
            }

            /// @use-src 0:"C.sol"
            object "C" {
                code {
                    function load(i) -> r { r := calldataload(i) }
                    /// @src 0:10:20
                    sstore(load(0), load(1))
                }
            }
        }
    }

    /// @use-src 0:"C.sol"
    object "C" {
        code {
            function load(i) -> r { r := calldataload(i) }
            /// @src 0:10:20
            sstore(load(0), load(1))
        }
    }

    /// @use-src 0:"D.sol"
    object "D" {
        code {
            function load(i) -> r { r := calldataload(i) }
            /// @src 0:10:20
            sstore(load(0), load(1))
        }
    }
}
// ====
// EVMVersion: >=shanghai
// optimizationPreset: full
// outputs: Assembly
// ----
// Assembly:
//     /* "A.sol":10:20   */
//   sstore(calldataload(0x00), calldataload(0x01))
//   stop
// stop
//
// sub_0: assembly {
//         /* "B.sol":10:20   */
//       sstore(calldataload(0x00), calldataload(0x01))
//       stop
//     stop
//
//     sub_0: assembly {
//             /* "A.sol":10:20   */
//           sstore(calldataload(0x00), calldataload(0x01))
//           stop
//         stop
//
//         sub_0: assembly {
//                 /* "B.sol":10:20   */
//               sstore(calldataload(0x00), calldataload(0x01))
//               stop
//         }
//
//         sub_1: assembly {
//                 /* "C.sol":10:20   */
//               sstore(calldataload(0x00), calldataload(0x01))
//               stop
//         }
//     }
// }
//
// sub_1: assembly {
//         /* "C.sol":10:20   */
//       sstore(calldataload(0x00), calldataload(0x01))
//       stop
// }
//
// sub_2: assembly {
//         /* "D.sol":10:20   */
//       sstore(calldataload(0x00), calldataload(0x01))
//       stop
// }
