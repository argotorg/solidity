function helper(uint256 input) pure returns (uint256 output) {
    return input;
}

library L {
    function internalHelper(uint256 x) internal pure returns (uint256) {
        return x;
    }

    function externalHelper(uint256 y) external pure returns (uint256) {
        return y;
    }
}

contract Base {
    function inherited(uint256 value) public pure virtual returns (uint256 result) {
        return value;
    }
}

contract C is Base {
    function callHelpers(uint256 value) public pure returns (uint256 result) {
        return helper(L.internalHelper(value));
    }
}
// ----
// C.semantic.scopes | keys: ["11","21","42","60"]
// C.semantic.scopes.11.0.variableDefinitions[0].identifier: input
// C.semantic.scopes.11.0.variableDefinitions[1].identifier: output
// C.semantic.scopes.21.0.variableDefinitions[0].identifier: x
// C.semantic.scopes.21.0.variableDefinitions[1].identifier: <PATH NOT FOUND>
// C.semantic.scopes.42.0.variableDefinitions[0].identifier: value
// C.semantic.scopes.42.0.variableDefinitions[1].identifier: result
// C.semantic.scopes.60.0.variableDefinitions[0].identifier: value
// C.semantic.scopes.60.0.variableDefinitions[1].identifier: result
// L.semantic.scopes | keys: ["31"]
// L.semantic.scopes.31.0.variableDefinitions[0].identifier: y
