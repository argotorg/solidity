// Pins down evaluation order and single-evaluation for indexed
// (compound) assignment:
//   - In `a[f()] = g()`, the RHS `g()` is evaluated before the LHS
//     index `f()`, so RHS side effects are observable when the index
//     is computed.
//   - In `a[f()] += v`, the LHS index `f()` is evaluated exactly once;
//     the slot computation is not re-evaluated for the write side.
contract C {
    uint[2] public a;
    uint public counter;

    function bumpIdx() internal returns (uint) {
        counter += 1;
        return counter - 1;
    }

    function calculateVal() internal returns (uint) {
        return 10 * (counter + 100);
    }

    function run() public returns (uint c, uint a0, uint a1) {
        a[bumpIdx()] = calculateVal();
        a[bumpIdx()] = calculateVal();
        c = counter;
        a0 = a[0];
        a1 = a[1];
    }
}
// ----
// run() -> 2, 1000, 1010
