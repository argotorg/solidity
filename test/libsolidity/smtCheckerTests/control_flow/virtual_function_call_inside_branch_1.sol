contract Context {}

contract ERC20 is Context {
    function approve() public virtual { _approve(); }
    function _approve() internal virtual {}
}

contract __unstable__ERC20Owned is ERC20 {
    function _approve() internal override {
        if (true) {
            super._approve();
        }
    }
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
