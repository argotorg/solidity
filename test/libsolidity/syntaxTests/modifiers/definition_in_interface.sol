interface I {
    modifier m { _; }
    modifier mu;
}
// ----
// TypeError 6408: (18-35): Modifiers cannot be defined or declared in interfaces.
// TypeError 6408: (40-52): Modifiers cannot be defined or declared in interfaces.
// TypeError 8063: (40-52): Modifiers without implementation are not allowed.
