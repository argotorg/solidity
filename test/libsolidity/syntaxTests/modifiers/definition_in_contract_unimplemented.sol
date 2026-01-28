contract C {
    modifier mu;
    modifier muv virtual;
}
// ----
// Warning 8429: (34-55): Virtual modifiers are deprecated and scheduled for removal.
// TypeError 3656: (0-57): Contract "C" should be marked as abstract.
// TypeError 8063: (17-29): Modifiers without implementation must be marked virtual.
