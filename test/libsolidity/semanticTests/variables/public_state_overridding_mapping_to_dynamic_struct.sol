pragma abicoder               v2;

struct S { uint256 v; string s; }

contract A
{
	function test(uint256 x) external virtual returns (S memory r)
	{
	    r.v = x;
	    r.s = "test";
	}
}
contract X is A
{
	mapping(uint256 => S) public override test;

	function set() public { test[42].v = 2; test[42].s = "statevar"; }
}
// ----
// test(uint256): 0 -> 0x20, 0, 0x40, 0
// test(uint256): 42 -> 0x20, 0, 0x40, 0
// set() ->
// test(uint256): 0 -> 0x20, 0, 0x40, 0
// test(uint256): 42 -> 0x20, 2, 0x40, 8, "statevar"
