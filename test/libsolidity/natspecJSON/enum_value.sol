contract C {
    enum Color {
        /// @custom red color
        Red,
        /// @title example of title
        /// @author example of author
        /// @notice example of notice
        /// @dev example of dev
        Green
        /// @notice beyond last value
    }
}
// ----
// ----
// :C devdoc
// {
//     "kind": "dev",
//     "methods": {},
//     "version": 1
// }
//
// :C userdoc
// {
//     "kind": "user",
//     "methods": {},
//     "version": 1
// }
