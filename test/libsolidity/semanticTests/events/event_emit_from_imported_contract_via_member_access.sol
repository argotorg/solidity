==== Source: a ====
event Transfer(address indexed _from, address indexed _to, uint256 _value);
==== Source: b ====
import * as Test2 from "a";

contract A {
    function returnAddress() external {
        emit Test2.Transfer(address(11), address(12), 13);
    }
}
// ----
// returnAddress() ->
// ~ emit Transfer(address,address,uint256): #0x0b, #0x0c, 0x0d
