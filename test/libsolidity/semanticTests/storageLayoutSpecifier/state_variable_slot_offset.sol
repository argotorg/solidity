contract C layout at 7 {
    int8 public x;
    int32 public y;
    uint256 public z;

    function xSlotOffset() public returns(uint s, uint o) { assembly { s := x.slot o := x.offset } }
    function ySlotOffset() public returns(uint s, uint o) { assembly { s := y.slot o := y.offset } }
    function zSlotOffset() public returns(uint s, uint o) { assembly { s := z.slot o := z.offset } }
}
// ----
// xSlotOffset() -> 7, 0
// ySlotOffset() -> 7, 1
// zSlotOffset() -> 8, 0
