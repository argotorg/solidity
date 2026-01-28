{
    function f() -> x { pop(address()) { pop(callvalue()) } }

     pop(f())
}
// ====
// stackOptimization: true
// EVMVersion: =current
// ----
//     /* "":74:77   */
//   tag_2
//   tag_1
//   jump	// in
// tag_2:
//     /* "":70:78   */
//   pop
//     /* "":0:80   */
//   stop
//     /* "":6:63   */
// tag_1:
//     /* "":22:23   */
//   0x00
//     /* "":6:63   */
//   swap1
//     /* "":30:39   */
//   address
//     /* "":26:40   */
//   pop
//     /* "":47:58   */
//   callvalue
//     /* "":43:59   */
//   pop
//     /* "":6:63   */
//   jump	// out
