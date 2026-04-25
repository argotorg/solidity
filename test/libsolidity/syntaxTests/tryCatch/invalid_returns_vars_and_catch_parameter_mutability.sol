contract C {
    function f() public returns (uint, uint) {
        try this.f() returns (uint constant a, uint immutable b) {
        } catch Error(string memory immutable x) {
            x;
        }

        try this.f() returns (uint a, uint b) {
        } catch (bytes memory immutable x) {
            x;
        }

        try this.f() returns (uint a, uint b) {
        } catch Error(string memory constant x) {
            x;
        }

        try this.f() returns (uint a, uint b) {
        } catch (bytes memory constant x) {
            x;
        }
    }
}
// ----
// ParserError 3548: (407-415): Location already specified.
// ParserError 3548: (525-533): Location already specified.
