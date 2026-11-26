/// @use-src 0:"A.sol", 9:"B.sol"
object "C" {
    code {
        /// @src 0:10:20
        sstore(0, calldatasize())
        /// @src 9:30:40
        stop()
    }
    /// @use-src 14:"A.sol", 19:"B.sol"
    object "runtime" {
        code {
            /// @src 19:50:60
            sstore(0, calldatasize())
            /// @src 14:70:80
            stop()
        }
    }
}
