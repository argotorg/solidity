function helper(uint256 input) pure returns (uint256 output) {
    return input;
}

contract Base {
    function inherited(uint256 value) public pure returns (uint256 result) {
        return value;
    }
}

contract C is Base {
    function callHelper(uint256 value) public pure returns (uint256 result) {
        return helper(value);
    }
}
// ----
// C.semantic.scopes | keys: ["11", "21", "36"]
// C.semantic.scopes.11.0.variableDefinitions[0].identifier: input
// C.semantic.scopes.11.0.variableDefinitions[1].identifier: output
// C.semantic.scopes.21.0.variableDefinitions[0].identifier: value
// C.semantic.scopes.21.0.variableDefinitions[1].identifier: result
// C.semantic.scopes.36.0.variableDefinitions[0].identifier: value
// C.semantic.scopes.36.0.variableDefinitions[1].identifier: result
// C.semantic.scopes.11.0.variableDefinitions[0].phase: materialized
// C.semantic.scopes.21.0.variableDefinitions[0].pointer.location: stack
// C.semantic.scopes.36.0.variableDefinitions[0].pointer.location: stack
