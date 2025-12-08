contract A { modifier mod(uint a) virtual { _; } }
contract B is A { modifier mod(uint a) override { _; } }
// ----
// Warning 8429: (13-48): Virtual modifiers are deprecated and scheduled for removal.
