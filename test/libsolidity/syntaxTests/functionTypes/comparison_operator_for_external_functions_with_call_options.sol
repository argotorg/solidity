contract C {
    function external_test_function() payable external {}
    function comparison_operator_for_external_function_with_extra_slots() external returns (bool) {
        return (
            (this.external_test_function{value: 4} == this.external_test_function) &&
            (this.external_test_function{value: 4} == this.external_test_function{value: 4})
        );
    }
}
// ----
// TypeError 2271: (201-269): Built-in binary operator == cannot be applied to types function () payable external and function () payable external.
// TypeError 2271: (287-365): Built-in binary operator == cannot be applied to types function () payable external and function () payable external.
