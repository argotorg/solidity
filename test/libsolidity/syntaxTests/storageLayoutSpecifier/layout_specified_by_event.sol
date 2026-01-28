event MyEvent();
contract C layout at MyEvent() {}
// ----
// TypeError 3132: (38-47): Event invocations have to be prefixed by "emit".
