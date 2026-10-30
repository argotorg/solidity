contract C {
    modifier mu;
}
// ----
// TypeError 3656: (0-31): Contract "C" should be marked as abstract.
// TypeError 8063: (17-29): Modifiers without implementation are not allowed.
