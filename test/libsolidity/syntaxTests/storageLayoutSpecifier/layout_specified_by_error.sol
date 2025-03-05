error MyError();
contract C layout at MyError() {}
// ----
// TypeError 7757: (38-47): Errors can only be used with revert statements: "revert MyError(args);", or require functions: "require(condition, MyError(args))".
