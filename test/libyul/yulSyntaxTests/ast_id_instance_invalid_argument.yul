/// @use-src 0:"input.sol"
{
    /// @ast-id 5 @ast-id-instance abc
    let x := 1
    /// @ast-id-instance 3
    let y := 2
    sstore(x, y)
}
// ----
// SyntaxError 9913: (33-67): Invalid argument for @ast-id-instance.
