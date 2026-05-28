// Test that the parser workaround is not breaking.
struct error {uint a;}
contract C {
    error x;
}
// ----
// Warning 6335: (52-74): "error" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
