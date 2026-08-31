/// @use-src 0:"input.sol"
object "C_12_deployed" {
    /// @ast-id 12
    code {
        /// @src 0:60:160  "contract C {..."
        mstore(64, 128)

        pop(fun_f_11(7))

        /// @src 0:99:158  "function f(uint256 argument) public returns (uint256 result) {..."
        /// @ast-id 11
        function fun_f_11(var_argument_4) -> var_result_7 {
            sstore(0, var_argument_4)
            var_result_7 := var_argument_4
        }
        /// @src 0:60:160  "contract C {..."
    }
}
