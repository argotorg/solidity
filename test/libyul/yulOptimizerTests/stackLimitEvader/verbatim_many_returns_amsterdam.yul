{
    // Same as ``verbatim_many_returns``, but for EVM versions with DUPN/SWAPN,
    // which can reach 235 stack slots. Since verbatim is limited to 99 arguments and return values,
    // 136 additional variables are defined between the calls and kept alive across the second one.
    {
        mstore(0x40, memoryguard(128))
        let a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31, a32, a33, a34, a35, a36, a37, a38, a39, a40, a41, a42, a43, a44, a45, a46, a47, a48, a49, a50, a51, a52, a53, a54, a55, a56, a57, a58, a59, a60, a61, a62, a63, a64, a65, a66, a67, a68, a69, a70, a71, a72, a73, a74, a75, a76, a77, a78, a79, a80, a81, a82, a83, a84, a85, a86, a87, a88, a89, a90, a91, a92, a93, a94, a95, a96, a97, a98, a99 := verbatim_0i_99o("test")
        let x_1 := 1001
        let x_2 := 1002
        let x_3 := 1003
        let x_4 := 1004
        let x_5 := 1005
        let x_6 := 1006
        let x_7 := 1007
        let x_8 := 1008
        let x_9 := 1009
        let x_10 := 1010
        let x_11 := 1011
        let x_12 := 1012
        let x_13 := 1013
        let x_14 := 1014
        let x_15 := 1015
        let x_16 := 1016
        let x_17 := 1017
        let x_18 := 1018
        let x_19 := 1019
        let x_20 := 1020
        let x_21 := 1021
        let x_22 := 1022
        let x_23 := 1023
        let x_24 := 1024
        let x_25 := 1025
        let x_26 := 1026
        let x_27 := 1027
        let x_28 := 1028
        let x_29 := 1029
        let x_30 := 1030
        let x_31 := 1031
        let x_32 := 1032
        let x_33 := 1033
        let x_34 := 1034
        let x_35 := 1035
        let x_36 := 1036
        let x_37 := 1037
        let x_38 := 1038
        let x_39 := 1039
        let x_40 := 1040
        let x_41 := 1041
        let x_42 := 1042
        let x_43 := 1043
        let x_44 := 1044
        let x_45 := 1045
        let x_46 := 1046
        let x_47 := 1047
        let x_48 := 1048
        let x_49 := 1049
        let x_50 := 1050
        let x_51 := 1051
        let x_52 := 1052
        let x_53 := 1053
        let x_54 := 1054
        let x_55 := 1055
        let x_56 := 1056
        let x_57 := 1057
        let x_58 := 1058
        let x_59 := 1059
        let x_60 := 1060
        let x_61 := 1061
        let x_62 := 1062
        let x_63 := 1063
        let x_64 := 1064
        let x_65 := 1065
        let x_66 := 1066
        let x_67 := 1067
        let x_68 := 1068
        let x_69 := 1069
        let x_70 := 1070
        let x_71 := 1071
        let x_72 := 1072
        let x_73 := 1073
        let x_74 := 1074
        let x_75 := 1075
        let x_76 := 1076
        let x_77 := 1077
        let x_78 := 1078
        let x_79 := 1079
        let x_80 := 1080
        let x_81 := 1081
        let x_82 := 1082
        let x_83 := 1083
        let x_84 := 1084
        let x_85 := 1085
        let x_86 := 1086
        let x_87 := 1087
        let x_88 := 1088
        let x_89 := 1089
        let x_90 := 1090
        let x_91 := 1091
        let x_92 := 1092
        let x_93 := 1093
        let x_94 := 1094
        let x_95 := 1095
        let x_96 := 1096
        let x_97 := 1097
        let x_98 := 1098
        let x_99 := 1099
        let x_100 := 1100
        let x_101 := 1101
        let x_102 := 1102
        let x_103 := 1103
        let x_104 := 1104
        let x_105 := 1105
        let x_106 := 1106
        let x_107 := 1107
        let x_108 := 1108
        let x_109 := 1109
        let x_110 := 1110
        let x_111 := 1111
        let x_112 := 1112
        let x_113 := 1113
        let x_114 := 1114
        let x_115 := 1115
        let x_116 := 1116
        let x_117 := 1117
        let x_118 := 1118
        let x_119 := 1119
        let x_120 := 1120
        let x_121 := 1121
        let x_122 := 1122
        let x_123 := 1123
        let x_124 := 1124
        let x_125 := 1125
        let x_126 := 1126
        let x_127 := 1127
        let x_128 := 1128
        let x_129 := 1129
        let x_130 := 1130
        let x_131 := 1131
        let x_132 := 1132
        let x_133 := 1133
        let x_134 := 1134
        let x_135 := 1135
        let x_136 := 1136
        a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31, a32, a33, a34, a35, a36, a37, a38, a39, a40, a41, a42, a43, a44, a45, a46, a47, a48, a49, a50, a51, a52, a53, a54, a55, a56, a57, a58, a59, a60, a61, a62, a63, a64, a65, a66, a67, a68, a69, a70, a71, a72, a73, a74, a75, a76, a77, a78, a79, a80, a81, a82, a83, a84, a85, a86, a87, a88, a89, a90, a91, a92, a93, a94, a95, a96, a97, a98, a99 := verbatim_0i_99o("test")
        sstore(a1, 10)
        sstore(a99, 20)
        sstore(1001, x_1)
        sstore(1002, x_2)
        sstore(1003, x_3)
        sstore(1004, x_4)
        sstore(1005, x_5)
        sstore(1006, x_6)
        sstore(1007, x_7)
        sstore(1008, x_8)
        sstore(1009, x_9)
        sstore(1010, x_10)
        sstore(1011, x_11)
        sstore(1012, x_12)
        sstore(1013, x_13)
        sstore(1014, x_14)
        sstore(1015, x_15)
        sstore(1016, x_16)
        sstore(1017, x_17)
        sstore(1018, x_18)
        sstore(1019, x_19)
        sstore(1020, x_20)
        sstore(1021, x_21)
        sstore(1022, x_22)
        sstore(1023, x_23)
        sstore(1024, x_24)
        sstore(1025, x_25)
        sstore(1026, x_26)
        sstore(1027, x_27)
        sstore(1028, x_28)
        sstore(1029, x_29)
        sstore(1030, x_30)
        sstore(1031, x_31)
        sstore(1032, x_32)
        sstore(1033, x_33)
        sstore(1034, x_34)
        sstore(1035, x_35)
        sstore(1036, x_36)
        sstore(1037, x_37)
        sstore(1038, x_38)
        sstore(1039, x_39)
        sstore(1040, x_40)
        sstore(1041, x_41)
        sstore(1042, x_42)
        sstore(1043, x_43)
        sstore(1044, x_44)
        sstore(1045, x_45)
        sstore(1046, x_46)
        sstore(1047, x_47)
        sstore(1048, x_48)
        sstore(1049, x_49)
        sstore(1050, x_50)
        sstore(1051, x_51)
        sstore(1052, x_52)
        sstore(1053, x_53)
        sstore(1054, x_54)
        sstore(1055, x_55)
        sstore(1056, x_56)
        sstore(1057, x_57)
        sstore(1058, x_58)
        sstore(1059, x_59)
        sstore(1060, x_60)
        sstore(1061, x_61)
        sstore(1062, x_62)
        sstore(1063, x_63)
        sstore(1064, x_64)
        sstore(1065, x_65)
        sstore(1066, x_66)
        sstore(1067, x_67)
        sstore(1068, x_68)
        sstore(1069, x_69)
        sstore(1070, x_70)
        sstore(1071, x_71)
        sstore(1072, x_72)
        sstore(1073, x_73)
        sstore(1074, x_74)
        sstore(1075, x_75)
        sstore(1076, x_76)
        sstore(1077, x_77)
        sstore(1078, x_78)
        sstore(1079, x_79)
        sstore(1080, x_80)
        sstore(1081, x_81)
        sstore(1082, x_82)
        sstore(1083, x_83)
        sstore(1084, x_84)
        sstore(1085, x_85)
        sstore(1086, x_86)
        sstore(1087, x_87)
        sstore(1088, x_88)
        sstore(1089, x_89)
        sstore(1090, x_90)
        sstore(1091, x_91)
        sstore(1092, x_92)
        sstore(1093, x_93)
        sstore(1094, x_94)
        sstore(1095, x_95)
        sstore(1096, x_96)
        sstore(1097, x_97)
        sstore(1098, x_98)
        sstore(1099, x_99)
        sstore(1100, x_100)
        sstore(1101, x_101)
        sstore(1102, x_102)
        sstore(1103, x_103)
        sstore(1104, x_104)
        sstore(1105, x_105)
        sstore(1106, x_106)
        sstore(1107, x_107)
        sstore(1108, x_108)
        sstore(1109, x_109)
        sstore(1110, x_110)
        sstore(1111, x_111)
        sstore(1112, x_112)
        sstore(1113, x_113)
        sstore(1114, x_114)
        sstore(1115, x_115)
        sstore(1116, x_116)
        sstore(1117, x_117)
        sstore(1118, x_118)
        sstore(1119, x_119)
        sstore(1120, x_120)
        sstore(1121, x_121)
        sstore(1122, x_122)
        sstore(1123, x_123)
        sstore(1124, x_124)
        sstore(1125, x_125)
        sstore(1126, x_126)
        sstore(1127, x_127)
        sstore(1128, x_128)
        sstore(1129, x_129)
        sstore(1130, x_130)
        sstore(1131, x_131)
        sstore(1132, x_132)
        sstore(1133, x_133)
        sstore(1134, x_134)
        sstore(1135, x_135)
        sstore(1136, x_136)
    }
}
// ====
// EVMVersion: >=amsterdam
// ----
// step: stackLimitEvader
//
// {
//     {
//         mstore(0x40, memoryguard(0xa0))
//         let a1_1, a2_2, a3_3, a4_4, a5_5, a6_6, a7_7, a8_8, a9_9, a10_10, a11_11, a12_12, a13_13, a14_14, a15_15, a16_16, a17_17, a18_18, a19_19, a20_20, a21_21, a22_22, a23_23, a24_24, a25_25, a26_26, a27_27, a28_28, a29_29, a30_30, a31_31, a32_32, a33_33, a34_34, a35_35, a36_36, a37_37, a38_38, a39_39, a40_40, a41_41, a42_42, a43_43, a44_44, a45_45, a46_46, a47_47, a48_48, a49_49, a50_50, a51_51, a52_52, a53_53, a54_54, a55_55, a56_56, a57_57, a58_58, a59_59, a60_60, a61_61, a62_62, a63_63, a64_64, a65_65, a66_66, a67_67, a68_68, a69_69, a70_70, a71_71, a72_72, a73_73, a74_74, a75_75, a76_76, a77_77, a78_78, a79_79, a80_80, a81_81, a82_82, a83_83, a84_84, a85_85, a86_86, a87_87, a88_88, a89_89, a90_90, a91_91, a92_92, a93_93, a94_94, a95_95, a96_96, a97_97, a98_98, a99_99 := verbatim_0i_99o("test")
//         mstore(0x80, a1_1)
//         let a99 := a99_99
//         let a98 := a98_98
//         let a97 := a97_97
//         let a96 := a96_96
//         let a95 := a95_95
//         let a94 := a94_94
//         let a93 := a93_93
//         let a92 := a92_92
//         let a91 := a91_91
//         let a90 := a90_90
//         let a89 := a89_89
//         let a88 := a88_88
//         let a87 := a87_87
//         let a86 := a86_86
//         let a85 := a85_85
//         let a84 := a84_84
//         let a83 := a83_83
//         let a82 := a82_82
//         let a81 := a81_81
//         let a80 := a80_80
//         let a79 := a79_79
//         let a78 := a78_78
//         let a77 := a77_77
//         let a76 := a76_76
//         let a75 := a75_75
//         let a74 := a74_74
//         let a73 := a73_73
//         let a72 := a72_72
//         let a71 := a71_71
//         let a70 := a70_70
//         let a69 := a69_69
//         let a68 := a68_68
//         let a67 := a67_67
//         let a66 := a66_66
//         let a65 := a65_65
//         let a64 := a64_64
//         let a63 := a63_63
//         let a62 := a62_62
//         let a61 := a61_61
//         let a60 := a60_60
//         let a59 := a59_59
//         let a58 := a58_58
//         let a57 := a57_57
//         let a56 := a56_56
//         let a55 := a55_55
//         let a54 := a54_54
//         let a53 := a53_53
//         let a52 := a52_52
//         let a51 := a51_51
//         let a50 := a50_50
//         let a49 := a49_49
//         let a48 := a48_48
//         let a47 := a47_47
//         let a46 := a46_46
//         let a45 := a45_45
//         let a44 := a44_44
//         let a43 := a43_43
//         let a42 := a42_42
//         let a41 := a41_41
//         let a40 := a40_40
//         let a39 := a39_39
//         let a38 := a38_38
//         let a37 := a37_37
//         let a36 := a36_36
//         let a35 := a35_35
//         let a34 := a34_34
//         let a33 := a33_33
//         let a32 := a32_32
//         let a31 := a31_31
//         let a30 := a30_30
//         let a29 := a29_29
//         let a28 := a28_28
//         let a27 := a27_27
//         let a26 := a26_26
//         let a25 := a25_25
//         let a24 := a24_24
//         let a23 := a23_23
//         let a22 := a22_22
//         let a21 := a21_21
//         let a20 := a20_20
//         let a19 := a19_19
//         let a18 := a18_18
//         let a17 := a17_17
//         let a16 := a16_16
//         let a15 := a15_15
//         let a14 := a14_14
//         let a13 := a13_13
//         let a12 := a12_12
//         let a11 := a11_11
//         let a10 := a10_10
//         let a9 := a9_9
//         let a8 := a8_8
//         let a7 := a7_7
//         let a6 := a6_6
//         let a5 := a5_5
//         let a4 := a4_4
//         let a3 := a3_3
//         let a2 := a2_2
//         let x_1 := 1001
//         let x_2 := 1002
//         let x_3 := 1003
//         let x_4 := 1004
//         let x_5 := 1005
//         let x_6 := 1006
//         let x_7 := 1007
//         let x_8 := 1008
//         let x_9 := 1009
//         let x_10 := 1010
//         let x_11 := 1011
//         let x_12 := 1012
//         let x_13 := 1013
//         let x_14 := 1014
//         let x_15 := 1015
//         let x_16 := 1016
//         let x_17 := 1017
//         let x_18 := 1018
//         let x_19 := 1019
//         let x_20 := 1020
//         let x_21 := 1021
//         let x_22 := 1022
//         let x_23 := 1023
//         let x_24 := 1024
//         let x_25 := 1025
//         let x_26 := 1026
//         let x_27 := 1027
//         let x_28 := 1028
//         let x_29 := 1029
//         let x_30 := 1030
//         let x_31 := 1031
//         let x_32 := 1032
//         let x_33 := 1033
//         let x_34 := 1034
//         let x_35 := 1035
//         let x_36 := 1036
//         let x_37 := 1037
//         let x_38 := 1038
//         let x_39 := 1039
//         let x_40 := 1040
//         let x_41 := 1041
//         let x_42 := 1042
//         let x_43 := 1043
//         let x_44 := 1044
//         let x_45 := 1045
//         let x_46 := 1046
//         let x_47 := 1047
//         let x_48 := 1048
//         let x_49 := 1049
//         let x_50 := 1050
//         let x_51 := 1051
//         let x_52 := 1052
//         let x_53 := 1053
//         let x_54 := 1054
//         let x_55 := 1055
//         let x_56 := 1056
//         let x_57 := 1057
//         let x_58 := 1058
//         let x_59 := 1059
//         let x_60 := 1060
//         let x_61 := 1061
//         let x_62 := 1062
//         let x_63 := 1063
//         let x_64 := 1064
//         let x_65 := 1065
//         let x_66 := 1066
//         let x_67 := 1067
//         let x_68 := 1068
//         let x_69 := 1069
//         let x_70 := 1070
//         let x_71 := 1071
//         let x_72 := 1072
//         let x_73 := 1073
//         let x_74 := 1074
//         let x_75 := 1075
//         let x_76 := 1076
//         let x_77 := 1077
//         let x_78 := 1078
//         let x_79 := 1079
//         let x_80 := 1080
//         let x_81 := 1081
//         let x_82 := 1082
//         let x_83 := 1083
//         let x_84 := 1084
//         let x_85 := 1085
//         let x_86 := 1086
//         let x_87 := 1087
//         let x_88 := 1088
//         let x_89 := 1089
//         let x_90 := 1090
//         let x_91 := 1091
//         let x_92 := 1092
//         let x_93 := 1093
//         let x_94 := 1094
//         let x_95 := 1095
//         let x_96 := 1096
//         let x_97 := 1097
//         let x_98 := 1098
//         let x_99 := 1099
//         let x_100 := 1100
//         let x_101 := 1101
//         let x_102 := 1102
//         let x_103 := 1103
//         let x_104 := 1104
//         let x_105 := 1105
//         let x_106 := 1106
//         let x_107 := 1107
//         let x_108 := 1108
//         let x_109 := 1109
//         let x_110 := 1110
//         let x_111 := 1111
//         let x_112 := 1112
//         let x_113 := 1113
//         let x_114 := 1114
//         let x_115 := 1115
//         let x_116 := 1116
//         let x_117 := 1117
//         let x_118 := 1118
//         let x_119 := 1119
//         let x_120 := 1120
//         let x_121 := 1121
//         let x_122 := 1122
//         let x_123 := 1123
//         let x_124 := 1124
//         let x_125 := 1125
//         let x_126 := 1126
//         let x_127 := 1127
//         let x_128 := 1128
//         let x_129 := 1129
//         let x_130 := 1130
//         let x_131 := 1131
//         let x_132 := 1132
//         let x_133 := 1133
//         let x_134 := 1134
//         let x_135 := 1135
//         let x_136 := 1136
//         let a1_100, a2_101, a3_102, a4_103, a5_104, a6_105, a7_106, a8_107, a9_108, a10_109, a11_110, a12_111, a13_112, a14_113, a15_114, a16_115, a17_116, a18_117, a19_118, a20_119, a21_120, a22_121, a23_122, a24_123, a25_124, a26_125, a27_126, a28_127, a29_128, a30_129, a31_130, a32_131, a33_132, a34_133, a35_134, a36_135, a37_136, a38_137, a39_138, a40_139, a41_140, a42_141, a43_142, a44_143, a45_144, a46_145, a47_146, a48_147, a49_148, a50_149, a51_150, a52_151, a53_152, a54_153, a55_154, a56_155, a57_156, a58_157, a59_158, a60_159, a61_160, a62_161, a63_162, a64_163, a65_164, a66_165, a67_166, a68_167, a69_168, a70_169, a71_170, a72_171, a73_172, a74_173, a75_174, a76_175, a77_176, a78_177, a79_178, a80_179, a81_180, a82_181, a83_182, a84_183, a85_184, a86_185, a87_186, a88_187, a89_188, a90_189, a91_190, a92_191, a93_192, a94_193, a95_194, a96_195, a97_196, a98_197, a99_198 := verbatim_0i_99o("test")
//         mstore(0x80, a1_100)
//         a99 := a99_198
//         a98 := a98_197
//         a97 := a97_196
//         a96 := a96_195
//         a95 := a95_194
//         a94 := a94_193
//         a93 := a93_192
//         a92 := a92_191
//         a91 := a91_190
//         a90 := a90_189
//         a89 := a89_188
//         a88 := a88_187
//         a87 := a87_186
//         a86 := a86_185
//         a85 := a85_184
//         a84 := a84_183
//         a83 := a83_182
//         a82 := a82_181
//         a81 := a81_180
//         a80 := a80_179
//         a79 := a79_178
//         a78 := a78_177
//         a77 := a77_176
//         a76 := a76_175
//         a75 := a75_174
//         a74 := a74_173
//         a73 := a73_172
//         a72 := a72_171
//         a71 := a71_170
//         a70 := a70_169
//         a69 := a69_168
//         a68 := a68_167
//         a67 := a67_166
//         a66 := a66_165
//         a65 := a65_164
//         a64 := a64_163
//         a63 := a63_162
//         a62 := a62_161
//         a61 := a61_160
//         a60 := a60_159
//         a59 := a59_158
//         a58 := a58_157
//         a57 := a57_156
//         a56 := a56_155
//         a55 := a55_154
//         a54 := a54_153
//         a53 := a53_152
//         a52 := a52_151
//         a51 := a51_150
//         a50 := a50_149
//         a49 := a49_148
//         a48 := a48_147
//         a47 := a47_146
//         a46 := a46_145
//         a45 := a45_144
//         a44 := a44_143
//         a43 := a43_142
//         a42 := a42_141
//         a41 := a41_140
//         a40 := a40_139
//         a39 := a39_138
//         a38 := a38_137
//         a37 := a37_136
//         a36 := a36_135
//         a35 := a35_134
//         a34 := a34_133
//         a33 := a33_132
//         a32 := a32_131
//         a31 := a31_130
//         a30 := a30_129
//         a29 := a29_128
//         a28 := a28_127
//         a27 := a27_126
//         a26 := a26_125
//         a25 := a25_124
//         a24 := a24_123
//         a23 := a23_122
//         a22 := a22_121
//         a21 := a21_120
//         a20 := a20_119
//         a19 := a19_118
//         a18 := a18_117
//         a17 := a17_116
//         a16 := a16_115
//         a15 := a15_114
//         a14 := a14_113
//         a13 := a13_112
//         a12 := a12_111
//         a11 := a11_110
//         a10 := a10_109
//         a9 := a9_108
//         a8 := a8_107
//         a7 := a7_106
//         a6 := a6_105
//         a5 := a5_104
//         a4 := a4_103
//         a3 := a3_102
//         a2 := a2_101
//         sstore(mload(0x80), 10)
//         sstore(a99, 20)
//         sstore(1001, x_1)
//         sstore(1002, x_2)
//         sstore(1003, x_3)
//         sstore(1004, x_4)
//         sstore(1005, x_5)
//         sstore(1006, x_6)
//         sstore(1007, x_7)
//         sstore(1008, x_8)
//         sstore(1009, x_9)
//         sstore(1010, x_10)
//         sstore(1011, x_11)
//         sstore(1012, x_12)
//         sstore(1013, x_13)
//         sstore(1014, x_14)
//         sstore(1015, x_15)
//         sstore(1016, x_16)
//         sstore(1017, x_17)
//         sstore(1018, x_18)
//         sstore(1019, x_19)
//         sstore(1020, x_20)
//         sstore(1021, x_21)
//         sstore(1022, x_22)
//         sstore(1023, x_23)
//         sstore(1024, x_24)
//         sstore(1025, x_25)
//         sstore(1026, x_26)
//         sstore(1027, x_27)
//         sstore(1028, x_28)
//         sstore(1029, x_29)
//         sstore(1030, x_30)
//         sstore(1031, x_31)
//         sstore(1032, x_32)
//         sstore(1033, x_33)
//         sstore(1034, x_34)
//         sstore(1035, x_35)
//         sstore(1036, x_36)
//         sstore(1037, x_37)
//         sstore(1038, x_38)
//         sstore(1039, x_39)
//         sstore(1040, x_40)
//         sstore(1041, x_41)
//         sstore(1042, x_42)
//         sstore(1043, x_43)
//         sstore(1044, x_44)
//         sstore(1045, x_45)
//         sstore(1046, x_46)
//         sstore(1047, x_47)
//         sstore(1048, x_48)
//         sstore(1049, x_49)
//         sstore(1050, x_50)
//         sstore(1051, x_51)
//         sstore(1052, x_52)
//         sstore(1053, x_53)
//         sstore(1054, x_54)
//         sstore(1055, x_55)
//         sstore(1056, x_56)
//         sstore(1057, x_57)
//         sstore(1058, x_58)
//         sstore(1059, x_59)
//         sstore(1060, x_60)
//         sstore(1061, x_61)
//         sstore(1062, x_62)
//         sstore(1063, x_63)
//         sstore(1064, x_64)
//         sstore(1065, x_65)
//         sstore(1066, x_66)
//         sstore(1067, x_67)
//         sstore(1068, x_68)
//         sstore(1069, x_69)
//         sstore(1070, x_70)
//         sstore(1071, x_71)
//         sstore(1072, x_72)
//         sstore(1073, x_73)
//         sstore(1074, x_74)
//         sstore(1075, x_75)
//         sstore(1076, x_76)
//         sstore(1077, x_77)
//         sstore(1078, x_78)
//         sstore(1079, x_79)
//         sstore(1080, x_80)
//         sstore(1081, x_81)
//         sstore(1082, x_82)
//         sstore(1083, x_83)
//         sstore(1084, x_84)
//         sstore(1085, x_85)
//         sstore(1086, x_86)
//         sstore(1087, x_87)
//         sstore(1088, x_88)
//         sstore(1089, x_89)
//         sstore(1090, x_90)
//         sstore(1091, x_91)
//         sstore(1092, x_92)
//         sstore(1093, x_93)
//         sstore(1094, x_94)
//         sstore(1095, x_95)
//         sstore(1096, x_96)
//         sstore(1097, x_97)
//         sstore(1098, x_98)
//         sstore(1099, x_99)
//         sstore(1100, x_100)
//         sstore(1101, x_101)
//         sstore(1102, x_102)
//         sstore(1103, x_103)
//         sstore(1104, x_104)
//         sstore(1105, x_105)
//         sstore(1106, x_106)
//         sstore(1107, x_107)
//         sstore(1108, x_108)
//         sstore(1109, x_109)
//         sstore(1110, x_110)
//         sstore(1111, x_111)
//         sstore(1112, x_112)
//         sstore(1113, x_113)
//         sstore(1114, x_114)
//         sstore(1115, x_115)
//         sstore(1116, x_116)
//         sstore(1117, x_117)
//         sstore(1118, x_118)
//         sstore(1119, x_119)
//         sstore(1120, x_120)
//         sstore(1121, x_121)
//         sstore(1122, x_122)
//         sstore(1123, x_123)
//         sstore(1124, x_124)
//         sstore(1125, x_125)
//         sstore(1126, x_126)
//         sstore(1127, x_127)
//         sstore(1128, x_128)
//         sstore(1129, x_129)
//         sstore(1130, x_130)
//         sstore(1131, x_131)
//         sstore(1132, x_132)
//         sstore(1133, x_133)
//         sstore(1134, x_134)
//         sstore(1135, x_135)
//         sstore(1136, x_136)
//     }
// }
