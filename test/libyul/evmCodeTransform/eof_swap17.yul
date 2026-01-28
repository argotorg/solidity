object "main" {
	code {
        // v17 is 17 slots deep in stack - all values in between are still needed - no way to avoid a swapn{17}.
        // Running this without EOF, as expected, throws stack-too-deep.
        function f(v00, v01, v02, v03, v04, v05, v06, v07, v08, v09, v10, v11, v12, v13, v14, v15, v16, v17) {
            sstore(17, v17)
            sstore(16, v16)
            sstore(15, v15)
            sstore(14, v14)
            sstore(13, v13)
            sstore(12, v12)
            sstore(11, v11)
            sstore(10, v10)
            sstore(9, v09)
            sstore(8, v08)
            sstore(7, v07)
            sstore(6, v06)
            sstore(5, v05)
            sstore(4, v04)
            sstore(3, v03)
            sstore(2, v02)
            sstore(1, v01)
            sstore(0, v00)
        }
        f(
            calldataload(0),
            calldataload(1),
            calldataload(2),
            calldataload(3),
            calldataload(4),
            calldataload(5),
            calldataload(6),
            calldataload(7),
            calldataload(8),
            calldataload(9),
            calldataload(10),
            calldataload(11),
            calldataload(12),
            calldataload(13),
            calldataload(14),
            calldataload(15),
            calldataload(16),
            calldataload(17)
        )
	}
}
// ====
// bytecodeFormat: >=EOFv1
// stackOptimization: true
// ----
//     /* "":1361:1363   */
//   0x11
//     /* "":1348:1364   */
//   calldataload
//     /* "":1331:1333   */
//   0x10
//     /* "":1318:1334   */
//   calldataload
//     /* "":1301:1303   */
//   0x0f
//     /* "":1288:1304   */
//   calldataload
//     /* "":1271:1273   */
//   0x0e
//     /* "":1258:1274   */
//   calldataload
//     /* "":1241:1243   */
//   0x0d
//     /* "":1228:1244   */
//   calldataload
//     /* "":1211:1213   */
//   0x0c
//     /* "":1198:1214   */
//   calldataload
//     /* "":1181:1183   */
//   0x0b
//     /* "":1168:1184   */
//   calldataload
//     /* "":1151:1153   */
//   0x0a
//     /* "":1138:1154   */
//   calldataload
//     /* "":1122:1123   */
//   0x09
//     /* "":1109:1124   */
//   calldataload
//     /* "":1093:1094   */
//   0x08
//     /* "":1080:1095   */
//   calldataload
//     /* "":1064:1065   */
//   0x07
//     /* "":1051:1066   */
//   calldataload
//     /* "":1035:1036   */
//   0x06
//     /* "":1022:1037   */
//   calldataload
//     /* "":1006:1007   */
//   0x05
//     /* "":993:1008   */
//   calldataload
//     /* "":977:978   */
//   0x04
//     /* "":964:979   */
//   calldataload
//     /* "":948:949   */
//   0x03
//     /* "":935:950   */
//   calldataload
//     /* "":919:920   */
//   0x02
//     /* "":906:921   */
//   calldataload
//     /* "":890:891   */
//   0x01
//     /* "":877:892   */
//   calldataload
//     /* "":861:862   */
//   0x00
//     /* "":848:863   */
//   calldataload
//     /* "":833:1374   */
//   callf{code_section_1}
//     /* "":22:1377   */
//   stop
//
// code_section_1: assembly {
//         /* "":218:824   */
//       swapn{17}
//       swap16
//       swap1
//       swap16
//       swap15
//       swap2
//       swap15
//       swap14
//       swap3
//       swap14
//       swap13
//       swap4
//       swap13
//       swap12
//       swap5
//       swap12
//       swap11
//       swap6
//       swap11
//       swap10
//       swap7
//       swap10
//       swap9
//       swap8
//       swap9
//         /* "":340:342   */
//       0x11
//         /* "":333:348   */
//       sstore
//         /* "":368:370   */
//       0x10
//         /* "":361:376   */
//       sstore
//         /* "":396:398   */
//       0x0f
//         /* "":389:404   */
//       sstore
//         /* "":424:426   */
//       0x0e
//         /* "":417:432   */
//       sstore
//         /* "":452:454   */
//       0x0d
//         /* "":445:460   */
//       sstore
//         /* "":480:482   */
//       0x0c
//         /* "":473:488   */
//       sstore
//         /* "":508:510   */
//       0x0b
//         /* "":501:516   */
//       sstore
//         /* "":536:538   */
//       0x0a
//         /* "":529:544   */
//       sstore
//         /* "":564:565   */
//       0x09
//         /* "":557:571   */
//       sstore
//         /* "":591:592   */
//       0x08
//         /* "":584:598   */
//       sstore
//         /* "":618:619   */
//       0x07
//         /* "":611:625   */
//       sstore
//         /* "":645:646   */
//       0x06
//         /* "":638:652   */
//       sstore
//         /* "":672:673   */
//       0x05
//         /* "":665:679   */
//       sstore
//         /* "":699:700   */
//       0x04
//         /* "":692:706   */
//       sstore
//         /* "":726:727   */
//       0x03
//         /* "":719:733   */
//       sstore
//         /* "":753:754   */
//       0x02
//         /* "":746:760   */
//       sstore
//         /* "":780:781   */
//       0x01
//         /* "":773:787   */
//       sstore
//         /* "":807:808   */
//       0x00
//         /* "":800:814   */
//       sstore
//         /* "":218:824   */
//       retf
// }
