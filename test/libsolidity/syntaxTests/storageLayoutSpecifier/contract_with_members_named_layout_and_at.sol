contract C layout at 0x1234 {
    uint layout;
    function at() public pure { }
}
// ----
// Warning 6335: (34-45): "layout" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
// Warning 6335: (51-80): "at" will be promoted to keyword in the future and will not be allowed as an identifier anymore.
