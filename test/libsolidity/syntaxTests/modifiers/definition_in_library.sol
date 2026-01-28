library L {
    modifier mv virtual { _; }
}
// ----
// Warning 8429: (16-42): Virtual modifiers are deprecated and scheduled for removal.
// TypeError 3275: (16-42): Modifiers in a library cannot be virtual.
