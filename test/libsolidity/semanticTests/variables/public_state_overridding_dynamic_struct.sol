pragma abicoder               v2;

struct S { uint256 v; string s; }

contract A
{
	function test() external virtual returns (S memory r)
	{
	    r.v = 42;
	    r.s = "test";
	}
}
contract X is A
{
	S public override test;

	function set() public { test.v = 2; test.s = "statevar"; }
}
// ----
// test() -> 0x20, 0, 0x40, 0
// set() ->
// test() -> 0x20, 2, 0x40, 8, "statevar"
