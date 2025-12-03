event EvExt();
error ErExt();

bytes32 constant eventExtSelectorGlobal = EvExt.selector;
bytes4 constant errorExtSelectorGlobal = ErExt.selector;

contract C {
    event Ev();
    error Er();

    bytes4 constant errorExtSelector = ErExt.selector;
    bytes32 constant eventExtSelector = EvExt.selector;

    bytes4 constant errorSelector = Er.selector;
    bytes32 constant eventSelector = Ev.selector;

    bytes4 constant errorSelectorC = C.Er.selector;
    bytes32 constant eventSelectorC = C.Ev.selector;
}
// ----
