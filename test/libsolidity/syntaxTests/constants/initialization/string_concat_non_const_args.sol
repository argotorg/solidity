contract A {
    string name = "name";

    function getName() public view returns (string memory) {
        return name;
    }

    string public constant abName = string.concat("aaaa", "bbbb", name);

    string public constant abgetName = string.concat("aaaa", "bbbb",getName());
}
// ----
// TypeError 8349: (165-200): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (242-281): Initial value for constant variable has to be compile-time constant.
