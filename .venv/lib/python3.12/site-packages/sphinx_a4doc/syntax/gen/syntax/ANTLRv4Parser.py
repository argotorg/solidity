# encoding: utf-8
from antlr4 import *
from io import StringIO
from typing.io import TextIO
import sys

def serializedATN():
    with StringIO() as buf:
        buf.write("\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\3@")
        buf.write("\u027b\4\2\t\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7")
        buf.write("\4\b\t\b\4\t\t\t\4\n\t\n\4\13\t\13\4\f\t\f\4\r\t\r\4\16")
        buf.write("\t\16\4\17\t\17\4\20\t\20\4\21\t\21\4\22\t\22\4\23\t\23")
        buf.write("\4\24\t\24\4\25\t\25\4\26\t\26\4\27\t\27\4\30\t\30\4\31")
        buf.write("\t\31\4\32\t\32\4\33\t\33\4\34\t\34\4\35\t\35\4\36\t\36")
        buf.write("\4\37\t\37\4 \t \4!\t!\4\"\t\"\4#\t#\4$\t$\4%\t%\4&\t")
        buf.write("&\4\'\t\'\4(\t(\4)\t)\4*\t*\4+\t+\4,\t,\4-\t-\4.\t.\4")
        buf.write("/\t/\4\60\t\60\4\61\t\61\4\62\t\62\4\63\t\63\4\64\t\64")
        buf.write("\4\65\t\65\4\66\t\66\4\67\t\67\48\t8\49\t9\4:\t:\4;\t")
        buf.write(";\4<\t<\4=\t=\4>\t>\3\2\7\2~\n\2\f\2\16\2\u0081\13\2\3")
        buf.write("\2\3\2\3\2\3\2\7\2\u0087\n\2\f\2\16\2\u008a\13\2\3\2\3")
        buf.write("\2\7\2\u008e\n\2\f\2\16\2\u0091\13\2\3\2\3\2\3\3\3\3\3")
        buf.write("\3\3\3\3\3\5\3\u009a\n\3\3\4\3\4\3\4\3\4\3\4\5\4\u00a1")
        buf.write("\n\4\3\5\3\5\3\5\3\5\7\5\u00a7\n\5\f\5\16\5\u00aa\13\5")
        buf.write("\3\5\3\5\3\6\3\6\3\6\3\6\3\7\3\7\3\7\7\7\u00b5\n\7\f\7")
        buf.write("\16\7\u00b8\13\7\3\7\3\7\3\7\5\7\u00bd\n\7\3\b\3\b\3\b")
        buf.write("\3\b\7\b\u00c3\n\b\f\b\16\b\u00c6\13\b\3\b\3\b\3\t\3\t")
        buf.write("\3\n\3\n\5\n\u00ce\n\n\3\n\3\n\3\13\3\13\5\13\u00d4\n")
        buf.write("\13\3\13\3\13\3\f\3\f\3\f\7\f\u00db\n\f\f\f\16\f\u00de")
        buf.write("\13\f\3\f\5\f\u00e1\n\f\3\r\3\r\3\r\3\r\5\r\u00e7\n\r")
        buf.write("\3\r\3\r\3\r\3\16\3\16\3\16\5\16\u00ef\n\16\3\17\3\17")
        buf.write("\7\17\u00f3\n\17\f\17\16\17\u00f6\13\17\3\17\3\17\3\20")
        buf.write("\3\20\7\20\u00fc\n\20\f\20\16\20\u00ff\13\20\3\20\3\20")
        buf.write("\3\21\3\21\3\21\3\21\7\21\u0107\n\21\f\21\16\21\u010a")
        buf.write("\13\21\3\22\7\22\u010d\n\22\f\22\16\22\u0110\13\22\3\23")
        buf.write("\7\23\u0113\n\23\f\23\16\23\u0116\13\23\3\23\3\23\5\23")
        buf.write("\u011a\n\23\3\24\7\24\u011d\n\24\f\24\16\24\u0120\13\24")
        buf.write("\3\24\5\24\u0123\n\24\3\24\3\24\5\24\u0127\n\24\3\24\5")
        buf.write("\24\u012a\n\24\3\24\5\24\u012d\n\24\3\24\5\24\u0130\n")
        buf.write("\24\3\24\7\24\u0133\n\24\f\24\16\24\u0136\13\24\3\24\3")
        buf.write("\24\3\24\3\24\3\24\3\25\7\25\u013e\n\25\f\25\16\25\u0141")
        buf.write("\13\25\3\25\5\25\u0144\n\25\3\26\3\26\3\26\3\26\3\27\3")
        buf.write("\27\3\27\3\30\3\30\5\30\u014f\n\30\3\31\3\31\3\31\3\32")
        buf.write("\3\32\3\32\3\32\7\32\u0158\n\32\f\32\16\32\u015b\13\32")
        buf.write("\3\33\3\33\3\33\3\34\3\34\3\34\3\34\3\35\6\35\u0165\n")
        buf.write("\35\r\35\16\35\u0166\3\36\3\36\3\37\3\37\3 \3 \3 \7 \u0170")
        buf.write("\n \f \16 \u0173\13 \3!\3!\3!\5!\u0178\n!\3\"\7\"\u017b")
        buf.write("\n\"\f\"\16\"\u017e\13\"\3\"\5\"\u0181\n\"\3\"\3\"\3\"")
        buf.write("\3\"\3\"\3#\3#\3$\3$\3$\7$\u018d\n$\f$\16$\u0190\13$\3")
        buf.write("%\3%\5%\u0194\n%\3%\5%\u0197\n%\3&\6&\u019a\n&\r&\16&")
        buf.write("\u019b\3\'\3\'\5\'\u01a0\n\'\3\'\3\'\5\'\u01a4\n\'\3\'")
        buf.write("\3\'\5\'\u01a8\n\'\3\'\3\'\5\'\u01ac\n\'\5\'\u01ae\n\'")
        buf.write("\3(\3(\3(\3(\5(\u01b4\n(\3)\3)\3)\3)\3*\3*\3*\3*\7*\u01be")
        buf.write("\n*\f*\16*\u01c1\13*\3+\3+\3+\3+\3+\3+\5+\u01c9\n+\3,")
        buf.write("\3,\5,\u01cd\n,\3-\3-\5-\u01d1\n-\3.\3.\3.\7.\u01d6\n")
        buf.write(".\f.\16.\u01d9\13.\3/\5/\u01dc\n/\3/\6/\u01df\n/\r/\16")
        buf.write("/\u01e0\3/\5/\u01e4\n/\3\60\3\60\5\60\u01e8\n\60\3\60")
        buf.write("\3\60\5\60\u01ec\n\60\3\60\3\60\5\60\u01f0\n\60\3\60\3")
        buf.write("\60\5\60\u01f4\n\60\3\60\5\60\u01f7\n\60\3\61\3\61\3\61")
        buf.write("\3\61\5\61\u01fd\n\61\3\62\3\62\5\62\u0201\n\62\3\62\3")
        buf.write("\62\5\62\u0205\n\62\3\62\3\62\5\62\u0209\n\62\5\62\u020b")
        buf.write("\n\62\3\63\3\63\3\63\3\63\3\63\3\63\5\63\u0213\n\63\3")
        buf.write("\63\5\63\u0216\n\63\3\64\3\64\3\64\3\64\3\64\5\64\u021d")
        buf.write("\n\64\5\64\u021f\n\64\3\65\3\65\3\65\3\65\5\65\u0225\n")
        buf.write("\65\3\66\3\66\3\66\3\66\7\66\u022b\n\66\f\66\16\66\u022e")
        buf.write("\13\66\3\66\3\66\3\67\3\67\5\67\u0234\n\67\3\67\3\67\5")
        buf.write("\67\u0238\n\67\3\67\3\67\5\67\u023c\n\67\38\38\58\u0240")
        buf.write("\n8\38\78\u0243\n8\f8\168\u0246\138\38\58\u0249\n8\38")
        buf.write("\38\38\39\39\59\u0250\n9\39\59\u0253\n9\3:\3:\3:\3:\3")
        buf.write(";\3;\5;\u025b\n;\3;\3;\5;\u025f\n;\5;\u0261\n;\3<\3<\3")
        buf.write("<\3<\7<\u0267\n<\f<\16<\u026a\13<\3<\3<\3=\3=\3=\3=\3")
        buf.write("=\5=\u0273\n=\5=\u0275\n=\3>\3>\5>\u0279\n>\3>\2\2?\2")
        buf.write("\4\6\b\n\f\16\20\22\24\26\30\32\34\36 \"$&(*,.\60\62\64")
        buf.write("\668:<>@BDFHJLNPRTVXZ\\^`bdfhjlnprtvxz\2\4\4\2\23\23\27")
        buf.write("\31\4\2++..\2\u02a8\2\177\3\2\2\2\4\u0099\3\2\2\2\6\u00a0")
        buf.write("\3\2\2\2\b\u00a2\3\2\2\2\n\u00ad\3\2\2\2\f\u00bc\3\2\2")
        buf.write("\2\16\u00be\3\2\2\2\20\u00c9\3\2\2\2\22\u00cb\3\2\2\2")
        buf.write("\24\u00d1\3\2\2\2\26\u00d7\3\2\2\2\30\u00e2\3\2\2\2\32")
        buf.write("\u00ee\3\2\2\2\34\u00f0\3\2\2\2\36\u00f9\3\2\2\2 \u0102")
        buf.write("\3\2\2\2\"\u010e\3\2\2\2$\u0114\3\2\2\2&\u011e\3\2\2\2")
        buf.write("(\u013f\3\2\2\2*\u0145\3\2\2\2,\u0149\3\2\2\2.\u014e\3")
        buf.write("\2\2\2\60\u0150\3\2\2\2\62\u0153\3\2\2\2\64\u015c\3\2")
        buf.write("\2\2\66\u015f\3\2\2\28\u0164\3\2\2\2:\u0168\3\2\2\2<\u016a")
        buf.write("\3\2\2\2>\u016c\3\2\2\2@\u0174\3\2\2\2B\u017c\3\2\2\2")
        buf.write("D\u0187\3\2\2\2F\u0189\3\2\2\2H\u0196\3\2\2\2J\u0199\3")
        buf.write("\2\2\2L\u01ad\3\2\2\2N\u01af\3\2\2\2P\u01b5\3\2\2\2R\u01b9")
        buf.write("\3\2\2\2T\u01c8\3\2\2\2V\u01cc\3\2\2\2X\u01d0\3\2\2\2")
        buf.write("Z\u01d2\3\2\2\2\\\u01e3\3\2\2\2^\u01f6\3\2\2\2`\u01f8")
        buf.write("\3\2\2\2b\u020a\3\2\2\2d\u0215\3\2\2\2f\u021e\3\2\2\2")
        buf.write("h\u0224\3\2\2\2j\u0226\3\2\2\2l\u023b\3\2\2\2n\u023d\3")
        buf.write("\2\2\2p\u024d\3\2\2\2r\u0254\3\2\2\2t\u0260\3\2\2\2v\u0262")
        buf.write("\3\2\2\2x\u0274\3\2\2\2z\u0278\3\2\2\2|~\7\6\2\2}|\3\2")
        buf.write("\2\2~\u0081\3\2\2\2\177}\3\2\2\2\177\u0080\3\2\2\2\u0080")
        buf.write("\u0082\3\2\2\2\u0081\177\3\2\2\2\u0082\u0083\5\4\3\2\u0083")
        buf.write("\u0084\5z>\2\u0084\u0088\7#\2\2\u0085\u0087\5\6\4\2\u0086")
        buf.write("\u0085\3\2\2\2\u0087\u008a\3\2\2\2\u0088\u0086\3\2\2\2")
        buf.write("\u0088\u0089\3\2\2\2\u0089\u008b\3\2\2\2\u008a\u0088\3")
        buf.write("\2\2\2\u008b\u008f\5\"\22\2\u008c\u008e\5 \21\2\u008d")
        buf.write("\u008c\3\2\2\2\u008e\u0091\3\2\2\2\u008f\u008d\3\2\2\2")
        buf.write("\u008f\u0090\3\2\2\2\u0090\u0092\3\2\2\2\u0091\u008f\3")
        buf.write("\2\2\2\u0092\u0093\7\2\2\3\u0093\3\3\2\2\2\u0094\u0095")
        buf.write("\7\24\2\2\u0095\u009a\7\26\2\2\u0096\u0097\7\25\2\2\u0097")
        buf.write("\u009a\7\26\2\2\u0098\u009a\7\26\2\2\u0099\u0094\3\2\2")
        buf.write("\2\u0099\u0096\3\2\2\2\u0099\u0098\3\2\2\2\u009a\5\3\2")
        buf.write("\2\2\u009b\u00a1\5\b\5\2\u009c\u00a1\5\16\b\2\u009d\u00a1")
        buf.write("\5\22\n\2\u009e\u00a1\5\24\13\2\u009f\u00a1\5\30\r\2\u00a0")
        buf.write("\u009b\3\2\2\2\u00a0\u009c\3\2\2\2\u00a0\u009d\3\2\2\2")
        buf.write("\u00a0\u009e\3\2\2\2\u00a0\u009f\3\2\2\2\u00a1\7\3\2\2")
        buf.write("\2\u00a2\u00a8\7\17\2\2\u00a3\u00a4\5\n\6\2\u00a4\u00a5")
        buf.write("\7#\2\2\u00a5\u00a7\3\2\2\2\u00a6\u00a3\3\2\2\2\u00a7")
        buf.write("\u00aa\3\2\2\2\u00a8\u00a6\3\2\2\2\u00a8\u00a9\3\2\2\2")
        buf.write("\u00a9\u00ab\3\2\2\2\u00aa\u00a8\3\2\2\2\u00ab\u00ac\7")
        buf.write("\'\2\2\u00ac\t\3\2\2\2\u00ad\u00ae\5z>\2\u00ae\u00af\7")
        buf.write("+\2\2\u00af\u00b0\5\f\7\2\u00b0\13\3\2\2\2\u00b1\u00b6")
        buf.write("\5z>\2\u00b2\u00b3\7\63\2\2\u00b3\u00b5\5z>\2\u00b4\u00b2")
        buf.write("\3\2\2\2\u00b5\u00b8\3\2\2\2\u00b6\u00b4\3\2\2\2\u00b6")
        buf.write("\u00b7\3\2\2\2\u00b7\u00bd\3\2\2\2\u00b8\u00b6\3\2\2\2")
        buf.write("\u00b9\u00bd\7\13\2\2\u00ba\u00bd\5\34\17\2\u00bb\u00bd")
        buf.write("\7\n\2\2\u00bc\u00b1\3\2\2\2\u00bc\u00b9\3\2\2\2\u00bc")
        buf.write("\u00ba\3\2\2\2\u00bc\u00bb\3\2\2\2\u00bd\r\3\2\2\2\u00be")
        buf.write("\u00bf\7\22\2\2\u00bf\u00c4\5\20\t\2\u00c0\u00c1\7\"\2")
        buf.write("\2\u00c1\u00c3\5\20\t\2\u00c2\u00c0\3\2\2\2\u00c3\u00c6")
        buf.write("\3\2\2\2\u00c4\u00c2\3\2\2\2\u00c4\u00c5\3\2\2\2\u00c5")
        buf.write("\u00c7\3\2\2\2\u00c6\u00c4\3\2\2\2\u00c7\u00c8\7#\2\2")
        buf.write("\u00c8\17\3\2\2\2\u00c9\u00ca\5z>\2\u00ca\21\3\2\2\2\u00cb")
        buf.write("\u00cd\7\20\2\2\u00cc\u00ce\5\26\f\2\u00cd\u00cc\3\2\2")
        buf.write("\2\u00cd\u00ce\3\2\2\2\u00ce\u00cf\3\2\2\2\u00cf\u00d0")
        buf.write("\7\'\2\2\u00d0\23\3\2\2\2\u00d1\u00d3\7\21\2\2\u00d2\u00d4")
        buf.write("\5\26\f\2\u00d3\u00d2\3\2\2\2\u00d3\u00d4\3\2\2\2\u00d4")
        buf.write("\u00d5\3\2\2\2\u00d5\u00d6\7\'\2\2\u00d6\25\3\2\2\2\u00d7")
        buf.write("\u00dc\5z>\2\u00d8\u00d9\7\"\2\2\u00d9\u00db\5z>\2\u00da")
        buf.write("\u00d8\3\2\2\2\u00db\u00de\3\2\2\2\u00dc\u00da\3\2\2\2")
        buf.write("\u00dc\u00dd\3\2\2\2\u00dd\u00e0\3\2\2\2\u00de\u00dc\3")
        buf.write("\2\2\2\u00df\u00e1\7\"\2\2\u00e0\u00df\3\2\2\2\u00e0\u00e1")
        buf.write("\3\2\2\2\u00e1\27\3\2\2\2\u00e2\u00e6\7\64\2\2\u00e3\u00e4")
        buf.write("\5\32\16\2\u00e4\u00e5\7!\2\2\u00e5\u00e7\3\2\2\2\u00e6")
        buf.write("\u00e3\3\2\2\2\u00e6\u00e7\3\2\2\2\u00e7\u00e8\3\2\2\2")
        buf.write("\u00e8\u00e9\5z>\2\u00e9\u00ea\5\34\17\2\u00ea\31\3\2")
        buf.write("\2\2\u00eb\u00ef\5z>\2\u00ec\u00ef\7\24\2\2\u00ed\u00ef")
        buf.write("\7\25\2\2\u00ee\u00eb\3\2\2\2\u00ee\u00ec\3\2\2\2\u00ee")
        buf.write("\u00ed\3\2\2\2\u00ef\33\3\2\2\2\u00f0\u00f4\7\16\2\2\u00f1")
        buf.write("\u00f3\7?\2\2\u00f2\u00f1\3\2\2\2\u00f3\u00f6\3\2\2\2")
        buf.write("\u00f4\u00f2\3\2\2\2\u00f4\u00f5\3\2\2\2\u00f5\u00f7\3")
        buf.write("\2\2\2\u00f6\u00f4\3\2\2\2\u00f7\u00f8\7=\2\2\u00f8\35")
        buf.write("\3\2\2\2\u00f9\u00fd\7\r\2\2\u00fa\u00fc\7<\2\2\u00fb")
        buf.write("\u00fa\3\2\2\2\u00fc\u00ff\3\2\2\2\u00fd\u00fb\3\2\2\2")
        buf.write("\u00fd\u00fe\3\2\2\2\u00fe\u0100\3\2\2\2\u00ff\u00fd\3")
        buf.write("\2\2\2\u0100\u0101\7:\2\2\u0101\37\3\2\2\2\u0102\u0103")
        buf.write("\7\37\2\2\u0103\u0104\5z>\2\u0104\u0108\7#\2\2\u0105\u0107")
        buf.write("\5B\"\2\u0106\u0105\3\2\2\2\u0107\u010a\3\2\2\2\u0108")
        buf.write("\u0106\3\2\2\2\u0108\u0109\3\2\2\2\u0109!\3\2\2\2\u010a")
        buf.write("\u0108\3\2\2\2\u010b\u010d\5$\23\2\u010c\u010b\3\2\2\2")
        buf.write("\u010d\u0110\3\2\2\2\u010e\u010c\3\2\2\2\u010e\u010f\3")
        buf.write("\2\2\2\u010f#\3\2\2\2\u0110\u010e\3\2\2\2\u0111\u0113")
        buf.write("\7\7\2\2\u0112\u0111\3\2\2\2\u0113\u0116\3\2\2\2\u0114")
        buf.write("\u0112\3\2\2\2\u0114\u0115\3\2\2\2\u0115\u0119\3\2\2\2")
        buf.write("\u0116\u0114\3\2\2\2\u0117\u011a\5&\24\2\u0118\u011a\5")
        buf.write("B\"\2\u0119\u0117\3\2\2\2\u0119\u0118\3\2\2\2\u011a%\3")
        buf.write("\2\2\2\u011b\u011d\7\6\2\2\u011c\u011b\3\2\2\2\u011d\u0120")
        buf.write("\3\2\2\2\u011e\u011c\3\2\2\2\u011e\u011f\3\2\2\2\u011f")
        buf.write("\u0122\3\2\2\2\u0120\u011e\3\2\2\2\u0121\u0123\58\35\2")
        buf.write("\u0122\u0121\3\2\2\2\u0122\u0123\3\2\2\2\u0123\u0124\3")
        buf.write("\2\2\2\u0124\u0126\7\4\2\2\u0125\u0127\5\36\20\2\u0126")
        buf.write("\u0125\3\2\2\2\u0126\u0127\3\2\2\2\u0127\u0129\3\2\2\2")
        buf.write("\u0128\u012a\5\60\31\2\u0129\u0128\3\2\2\2\u0129\u012a")
        buf.write("\3\2\2\2\u012a\u012c\3\2\2\2\u012b\u012d\5\62\32\2\u012c")
        buf.write("\u012b\3\2\2\2\u012c\u012d\3\2\2\2\u012d\u012f\3\2\2\2")
        buf.write("\u012e\u0130\5\64\33\2\u012f\u012e\3\2\2\2\u012f\u0130")
        buf.write("\3\2\2\2\u0130\u0134\3\2\2\2\u0131\u0133\5.\30\2\u0132")
        buf.write("\u0131\3\2\2\2\u0133\u0136\3\2\2\2\u0134\u0132\3\2\2\2")
        buf.write("\u0134\u0135\3\2\2\2\u0135\u0137\3\2\2\2\u0136\u0134\3")
        buf.write("\2\2\2\u0137\u0138\7 \2\2\u0138\u0139\5<\37\2\u0139\u013a")
        buf.write("\7#\2\2\u013a\u013b\5(\25\2\u013b\'\3\2\2\2\u013c\u013e")
        buf.write("\5*\26\2\u013d\u013c\3\2\2\2\u013e\u0141\3\2\2\2\u013f")
        buf.write("\u013d\3\2\2\2\u013f\u0140\3\2\2\2\u0140\u0143\3\2\2\2")
        buf.write("\u0141\u013f\3\2\2\2\u0142\u0144\5,\27\2\u0143\u0142\3")
        buf.write("\2\2\2\u0143\u0144\3\2\2\2\u0144)\3\2\2\2\u0145\u0146")
        buf.write("\7\35\2\2\u0146\u0147\5\36\20\2\u0147\u0148\5\34\17\2")
        buf.write("\u0148+\3\2\2\2\u0149\u014a\7\36\2\2\u014a\u014b\5\34")
        buf.write("\17\2\u014b-\3\2\2\2\u014c\u014f\5\b\5\2\u014d\u014f\5")
        buf.write("\66\34\2\u014e\u014c\3\2\2\2\u014e\u014d\3\2\2\2\u014f")
        buf.write("/\3\2\2\2\u0150\u0151\7\32\2\2\u0151\u0152\5\36\20\2\u0152")
        buf.write("\61\3\2\2\2\u0153\u0154\7\34\2\2\u0154\u0159\5z>\2\u0155")
        buf.write("\u0156\7\"\2\2\u0156\u0158\5z>\2\u0157\u0155\3\2\2\2\u0158")
        buf.write("\u015b\3\2\2\2\u0159\u0157\3\2\2\2\u0159\u015a\3\2\2\2")
        buf.write("\u015a\63\3\2\2\2\u015b\u0159\3\2\2\2\u015c\u015d\7\33")
        buf.write("\2\2\u015d\u015e\5\36\20\2\u015e\65\3\2\2\2\u015f\u0160")
        buf.write("\7\64\2\2\u0160\u0161\5z>\2\u0161\u0162\5\34\17\2\u0162")
        buf.write("\67\3\2\2\2\u0163\u0165\5:\36\2\u0164\u0163\3\2\2\2\u0165")
        buf.write("\u0166\3\2\2\2\u0166\u0164\3\2\2\2\u0166\u0167\3\2\2\2")
        buf.write("\u01679\3\2\2\2\u0168\u0169\t\2\2\2\u0169;\3\2\2\2\u016a")
        buf.write("\u016b\5> \2\u016b=\3\2\2\2\u016c\u0171\5@!\2\u016d\u016e")
        buf.write("\7\60\2\2\u016e\u0170\5@!\2\u016f\u016d\3\2\2\2\u0170")
        buf.write("\u0173\3\2\2\2\u0171\u016f\3\2\2\2\u0171\u0172\3\2\2\2")
        buf.write("\u0172?\3\2\2\2\u0173\u0171\3\2\2\2\u0174\u0177\5\\/\2")
        buf.write("\u0175\u0176\7\65\2\2\u0176\u0178\5z>\2\u0177\u0175\3")
        buf.write("\2\2\2\u0177\u0178\3\2\2\2\u0178A\3\2\2\2\u0179\u017b")
        buf.write("\7\6\2\2\u017a\u0179\3\2\2\2\u017b\u017e\3\2\2\2\u017c")
        buf.write("\u017a\3\2\2\2\u017c\u017d\3\2\2\2\u017d\u0180\3\2\2\2")
        buf.write("\u017e\u017c\3\2\2\2\u017f\u0181\7\23\2\2\u0180\u017f")
        buf.write("\3\2\2\2\u0180\u0181\3\2\2\2\u0181\u0182\3\2\2\2\u0182")
        buf.write("\u0183\7\3\2\2\u0183\u0184\7 \2\2\u0184\u0185\5D#\2\u0185")
        buf.write("\u0186\7#\2\2\u0186C\3\2\2\2\u0187\u0188\5F$\2\u0188E")
        buf.write("\3\2\2\2\u0189\u018e\5H%\2\u018a\u018b\7\60\2\2\u018b")
        buf.write("\u018d\5H%\2\u018c\u018a\3\2\2\2\u018d\u0190\3\2\2\2\u018e")
        buf.write("\u018c\3\2\2\2\u018e\u018f\3\2\2\2\u018fG\3\2\2\2\u0190")
        buf.write("\u018e\3\2\2\2\u0191\u0193\5J&\2\u0192\u0194\5R*\2\u0193")
        buf.write("\u0192\3\2\2\2\u0193\u0194\3\2\2\2\u0194\u0197\3\2\2\2")
        buf.write("\u0195\u0197\3\2\2\2\u0196\u0191\3\2\2\2\u0196\u0195\3")
        buf.write("\2\2\2\u0197I\3\2\2\2\u0198\u019a\5L\'\2\u0199\u0198\3")
        buf.write("\2\2\2\u019a\u019b\3\2\2\2\u019b\u0199\3\2\2\2\u019b\u019c")
        buf.write("\3\2\2\2\u019cK\3\2\2\2\u019d\u019f\5N(\2\u019e\u01a0")
        buf.write("\5b\62\2\u019f\u019e\3\2\2\2\u019f\u01a0\3\2\2\2\u01a0")
        buf.write("\u01ae\3\2\2\2\u01a1\u01a3\5d\63\2\u01a2\u01a4\5b\62\2")
        buf.write("\u01a3\u01a2\3\2\2\2\u01a3\u01a4\3\2\2\2\u01a4\u01ae\3")
        buf.write("\2\2\2\u01a5\u01a7\5P)\2\u01a6\u01a8\5b\62\2\u01a7\u01a6")
        buf.write("\3\2\2\2\u01a7\u01a8\3\2\2\2\u01a8\u01ae\3\2\2\2\u01a9")
        buf.write("\u01ab\5\34\17\2\u01aa\u01ac\7,\2\2\u01ab\u01aa\3\2\2")
        buf.write("\2\u01ab\u01ac\3\2\2\2\u01ac\u01ae\3\2\2\2\u01ad\u019d")
        buf.write("\3\2\2\2\u01ad\u01a1\3\2\2\2\u01ad\u01a5\3\2\2\2\u01ad")
        buf.write("\u01a9\3\2\2\2\u01aeM\3\2\2\2\u01af\u01b0\5z>\2\u01b0")
        buf.write("\u01b3\t\3\2\2\u01b1\u01b4\5d\63\2\u01b2\u01b4\5P)\2\u01b3")
        buf.write("\u01b1\3\2\2\2\u01b3\u01b2\3\2\2\2\u01b4O\3\2\2\2\u01b5")
        buf.write("\u01b6\7$\2\2\u01b6\u01b7\5F$\2\u01b7\u01b8\7%\2\2\u01b8")
        buf.write("Q\3\2\2\2\u01b9\u01ba\7(\2\2\u01ba\u01bf\5T+\2\u01bb\u01bc")
        buf.write("\7\"\2\2\u01bc\u01be\5T+\2\u01bd\u01bb\3\2\2\2\u01be\u01c1")
        buf.write("\3\2\2\2\u01bf\u01bd\3\2\2\2\u01bf\u01c0\3\2\2\2\u01c0")
        buf.write("S\3\2\2\2\u01c1\u01bf\3\2\2\2\u01c2\u01c3\5V,\2\u01c3")
        buf.write("\u01c4\7$\2\2\u01c4\u01c5\5X-\2\u01c5\u01c6\7%\2\2\u01c6")
        buf.write("\u01c9\3\2\2\2\u01c7\u01c9\5V,\2\u01c8\u01c2\3\2\2\2\u01c8")
        buf.write("\u01c7\3\2\2\2\u01c9U\3\2\2\2\u01ca\u01cd\5z>\2\u01cb")
        buf.write("\u01cd\7\37\2\2\u01cc\u01ca\3\2\2\2\u01cc\u01cb\3\2\2")
        buf.write("\2\u01cdW\3\2\2\2\u01ce\u01d1\5z>\2\u01cf\u01d1\7\n\2")
        buf.write("\2\u01d0\u01ce\3\2\2\2\u01d0\u01cf\3\2\2\2\u01d1Y\3\2")
        buf.write("\2\2\u01d2\u01d7\5\\/\2\u01d3\u01d4\7\60\2\2\u01d4\u01d6")
        buf.write("\5\\/\2\u01d5\u01d3\3\2\2\2\u01d6\u01d9\3\2\2\2\u01d7")
        buf.write("\u01d5\3\2\2\2\u01d7\u01d8\3\2\2\2\u01d8[\3\2\2\2\u01d9")
        buf.write("\u01d7\3\2\2\2\u01da\u01dc\5v<\2\u01db\u01da\3\2\2\2\u01db")
        buf.write("\u01dc\3\2\2\2\u01dc\u01de\3\2\2\2\u01dd\u01df\5^\60\2")
        buf.write("\u01de\u01dd\3\2\2\2\u01df\u01e0\3\2\2\2\u01e0\u01de\3")
        buf.write("\2\2\2\u01e0\u01e1\3\2\2\2\u01e1\u01e4\3\2\2\2\u01e2\u01e4")
        buf.write("\3\2\2\2\u01e3\u01db\3\2\2\2\u01e3\u01e2\3\2\2\2\u01e4")
        buf.write("]\3\2\2\2\u01e5\u01e7\5`\61\2\u01e6\u01e8\5b\62\2\u01e7")
        buf.write("\u01e6\3\2\2\2\u01e7\u01e8\3\2\2\2\u01e8\u01f7\3\2\2\2")
        buf.write("\u01e9\u01eb\5f\64\2\u01ea\u01ec\5b\62\2\u01eb\u01ea\3")
        buf.write("\2\2\2\u01eb\u01ec\3\2\2\2\u01ec\u01f7\3\2\2\2\u01ed\u01ef")
        buf.write("\5n8\2\u01ee\u01f0\5b\62\2\u01ef\u01ee\3\2\2\2\u01ef\u01f0")
        buf.write("\3\2\2\2\u01f0\u01f7\3\2\2\2\u01f1\u01f3\5\34\17\2\u01f2")
        buf.write("\u01f4\7,\2\2\u01f3\u01f2\3\2\2\2\u01f3\u01f4\3\2\2\2")
        buf.write("\u01f4\u01f7\3\2\2\2\u01f5\u01f7\7\6\2\2\u01f6\u01e5\3")
        buf.write("\2\2\2\u01f6\u01e9\3\2\2\2\u01f6\u01ed\3\2\2\2\u01f6\u01f1")
        buf.write("\3\2\2\2\u01f6\u01f5\3\2\2\2\u01f7_\3\2\2\2\u01f8\u01f9")
        buf.write("\5z>\2\u01f9\u01fc\t\3\2\2\u01fa\u01fd\5f\64\2\u01fb\u01fd")
        buf.write("\5n8\2\u01fc\u01fa\3\2\2\2\u01fc\u01fb\3\2\2\2\u01fda")
        buf.write("\3\2\2\2\u01fe\u0200\7,\2\2\u01ff\u0201\7,\2\2\u0200\u01ff")
        buf.write("\3\2\2\2\u0200\u0201\3\2\2\2\u0201\u020b\3\2\2\2\u0202")
        buf.write("\u0204\7-\2\2\u0203\u0205\7,\2\2\u0204\u0203\3\2\2\2\u0204")
        buf.write("\u0205\3\2\2\2\u0205\u020b\3\2\2\2\u0206\u0208\7/\2\2")
        buf.write("\u0207\u0209\7,\2\2\u0208\u0207\3\2\2\2\u0208\u0209\3")
        buf.write("\2\2\2\u0209\u020b\3\2\2\2\u020a\u01fe\3\2\2\2\u020a\u0202")
        buf.write("\3\2\2\2\u020a\u0206\3\2\2\2\u020bc\3\2\2\2\u020c\u0216")
        buf.write("\5r:\2\u020d\u0216\5t;\2\u020e\u0216\5h\65\2\u020f\u0216")
        buf.write("\7\5\2\2\u0210\u0212\7\63\2\2\u0211\u0213\5v<\2\u0212")
        buf.write("\u0211\3\2\2\2\u0212\u0213\3\2\2\2\u0213\u0216\3\2\2\2")
        buf.write("\u0214\u0216\7\6\2\2\u0215\u020c\3\2\2\2\u0215\u020d\3")
        buf.write("\2\2\2\u0215\u020e\3\2\2\2\u0215\u020f\3\2\2\2\u0215\u0210")
        buf.write("\3\2\2\2\u0215\u0214\3\2\2\2\u0216e\3\2\2\2\u0217\u021f")
        buf.write("\5t;\2\u0218\u021f\5p9\2\u0219\u021f\5h\65\2\u021a\u021c")
        buf.write("\7\63\2\2\u021b\u021d\5v<\2\u021c\u021b\3\2\2\2\u021c")
        buf.write("\u021d\3\2\2\2\u021d\u021f\3\2\2\2\u021e\u0217\3\2\2\2")
        buf.write("\u021e\u0218\3\2\2\2\u021e\u0219\3\2\2\2\u021e\u021a\3")
        buf.write("\2\2\2\u021fg\3\2\2\2\u0220\u0221\7\66\2\2\u0221\u0225")
        buf.write("\5l\67\2\u0222\u0223\7\66\2\2\u0223\u0225\5j\66\2\u0224")
        buf.write("\u0220\3\2\2\2\u0224\u0222\3\2\2\2\u0225i\3\2\2\2\u0226")
        buf.write("\u0227\7$\2\2\u0227\u022c\5l\67\2\u0228\u0229\7\60\2\2")
        buf.write("\u0229\u022b\5l\67\2\u022a\u0228\3\2\2\2\u022b\u022e\3")
        buf.write("\2\2\2\u022c\u022a\3\2\2\2\u022c\u022d\3\2\2\2\u022d\u022f")
        buf.write("\3\2\2\2\u022e\u022c\3\2\2\2\u022f\u0230\7%\2\2\u0230")
        buf.write("k\3\2\2\2\u0231\u0233\7\3\2\2\u0232\u0234\5v<\2\u0233")
        buf.write("\u0232\3\2\2\2\u0233\u0234\3\2\2\2\u0234\u023c\3\2\2\2")
        buf.write("\u0235\u0237\7\13\2\2\u0236\u0238\5v<\2\u0237\u0236\3")
        buf.write("\2\2\2\u0237\u0238\3\2\2\2\u0238\u023c\3\2\2\2\u0239\u023c")
        buf.write("\5r:\2\u023a\u023c\7\5\2\2\u023b\u0231\3\2\2\2\u023b\u0235")
        buf.write("\3\2\2\2\u023b\u0239\3\2\2\2\u023b\u023a\3\2\2\2\u023c")
        buf.write("m\3\2\2\2\u023d\u0248\7$\2\2\u023e\u0240\5\b\5\2\u023f")
        buf.write("\u023e\3\2\2\2\u023f\u0240\3\2\2\2\u0240\u0244\3\2\2\2")
        buf.write("\u0241\u0243\5\66\34\2\u0242\u0241\3\2\2\2\u0243\u0246")
        buf.write("\3\2\2\2\u0244\u0242\3\2\2\2\u0244\u0245\3\2\2\2\u0245")
        buf.write("\u0247\3\2\2\2\u0246\u0244\3\2\2\2\u0247\u0249\7 \2\2")
        buf.write("\u0248\u023f\3\2\2\2\u0248\u0249\3\2\2\2\u0249\u024a\3")
        buf.write("\2\2\2\u024a\u024b\5Z.\2\u024b\u024c\7%\2\2\u024co\3\2")
        buf.write("\2\2\u024d\u024f\7\4\2\2\u024e\u0250\5\36\20\2\u024f\u024e")
        buf.write("\3\2\2\2\u024f\u0250\3\2\2\2\u0250\u0252\3\2\2\2\u0251")
        buf.write("\u0253\5v<\2\u0252\u0251\3\2\2\2\u0252\u0253\3\2\2\2\u0253")
        buf.write("q\3\2\2\2\u0254\u0255\7\13\2\2\u0255\u0256\7\62\2\2\u0256")
        buf.write("\u0257\7\13\2\2\u0257s\3\2\2\2\u0258\u025a\7\3\2\2\u0259")
        buf.write("\u025b\5v<\2\u025a\u0259\3\2\2\2\u025a\u025b\3\2\2\2\u025b")
        buf.write("\u0261\3\2\2\2\u025c\u025e\7\13\2\2\u025d\u025f\5v<\2")
        buf.write("\u025e\u025d\3\2\2\2\u025e\u025f\3\2\2\2\u025f\u0261\3")
        buf.write("\2\2\2\u0260\u0258\3\2\2\2\u0260\u025c\3\2\2\2\u0261u")
        buf.write("\3\2\2\2\u0262\u0263\7)\2\2\u0263\u0268\5x=\2\u0264\u0265")
        buf.write("\7\"\2\2\u0265\u0267\5x=\2\u0266\u0264\3\2\2\2\u0267\u026a")
        buf.write("\3\2\2\2\u0268\u0266\3\2\2\2\u0268\u0269\3\2\2\2\u0269")
        buf.write("\u026b\3\2\2\2\u026a\u0268\3\2\2\2\u026b\u026c\7*\2\2")
        buf.write("\u026cw\3\2\2\2\u026d\u0275\5z>\2\u026e\u026f\5z>\2\u026f")
        buf.write("\u0272\7+\2\2\u0270\u0273\5z>\2\u0271\u0273\7\13\2\2\u0272")
        buf.write("\u0270\3\2\2\2\u0272\u0271\3\2\2\2\u0273\u0275\3\2\2\2")
        buf.write("\u0274\u026d\3\2\2\2\u0274\u026e\3\2\2\2\u0275y\3\2\2")
        buf.write("\2\u0276\u0279\7\4\2\2\u0277\u0279\7\3\2\2\u0278\u0276")
        buf.write("\3\2\2\2\u0278\u0277\3\2\2\2\u0279{\3\2\2\2X\177\u0088")
        buf.write("\u008f\u0099\u00a0\u00a8\u00b6\u00bc\u00c4\u00cd\u00d3")
        buf.write("\u00dc\u00e0\u00e6\u00ee\u00f4\u00fd\u0108\u010e\u0114")
        buf.write("\u0119\u011e\u0122\u0126\u0129\u012c\u012f\u0134\u013f")
        buf.write("\u0143\u014e\u0159\u0166\u0171\u0177\u017c\u0180\u018e")
        buf.write("\u0193\u0196\u019b\u019f\u01a3\u01a7\u01ab\u01ad\u01b3")
        buf.write("\u01bf\u01c8\u01cc\u01d0\u01d7\u01db\u01e0\u01e3\u01e7")
        buf.write("\u01eb\u01ef\u01f3\u01f6\u01fc\u0200\u0204\u0208\u020a")
        buf.write("\u0212\u0215\u021c\u021e\u0224\u022c\u0233\u0237\u023b")
        buf.write("\u023f\u0244\u0248\u024f\u0252\u025a\u025e\u0260\u0268")
        buf.write("\u0272\u0274\u0278")
        return buf.getvalue()


class ANTLRv4Parser ( Parser ):

    grammarFileName = "ANTLRv4Parser.g4"

    atn = ATNDeserializer().deserialize(serializedATN())

    decisionsToDFA = [ DFA(ds, i) for i, ds in enumerate(atn.decisionToState) ]

    sharedContextCache = PredictionContextCache()

    literalNames = [ "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                     "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                     "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                     "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                     "'import'", "'fragment'", "'lexer'", "'parser'", "'grammar'", 
                     "'protected'", "'public'", "'private'", "'returns'", 
                     "'locals'", "'throws'", "'catch'", "'finally'", "'mode'" ]

    symbolicNames = [ "<INVALID>", "TOKEN_REF", "RULE_REF", "LEXER_CHAR_SET", 
                      "DOC_COMMENT", "HEADER", "BLOCK_COMMENT", "LINE_COMMENT", 
                      "INT", "STRING_LITERAL", "UNTERMINATED_STRING_LITERAL", 
                      "BEGIN_ARGUMENT", "BEGIN_ACTION", "OPTIONS", "TOKENS", 
                      "CHANNELS", "IMPORT", "FRAGMENT", "LEXER", "PARSER", 
                      "GRAMMAR", "PROTECTED", "PUBLIC", "PRIVATE", "RETURNS", 
                      "LOCALS", "THROWS", "CATCH", "FINALLY", "MODE", "COLON", 
                      "COLONCOLON", "COMMA", "SEMI", "LPAREN", "RPAREN", 
                      "LBRACE", "RBRACE", "RARROW", "LT", "GT", "ASSIGN", 
                      "QUESTION", "STAR", "PLUS_ASSIGN", "PLUS", "OR", "DOLLAR", 
                      "RANGE", "DOT", "AT", "POUND", "NOT", "ID", "WS", 
                      "ERRCHAR", "END_ARGUMENT", "UNTERMINATED_ARGUMENT", 
                      "ARGUMENT_CONTENT", "END_ACTION", "UNTERMINATED_ACTION", 
                      "ACTION_CONTENT", "UNTERMINATED_CHAR_SET" ]

    RULE_grammarSpec = 0
    RULE_grammarType = 1
    RULE_prequelConstruct = 2
    RULE_optionsSpec = 3
    RULE_option = 4
    RULE_optionValue = 5
    RULE_delegateGrammars = 6
    RULE_delegateGrammar = 7
    RULE_tokensSpec = 8
    RULE_channelsSpec = 9
    RULE_idList = 10
    RULE_action = 11
    RULE_actionScopeName = 12
    RULE_actionBlock = 13
    RULE_argActionBlock = 14
    RULE_modeSpec = 15
    RULE_rules = 16
    RULE_ruleSpec = 17
    RULE_parserRuleSpec = 18
    RULE_exceptionGroup = 19
    RULE_exceptionHandler = 20
    RULE_finallyClause = 21
    RULE_rulePrequel = 22
    RULE_ruleReturns = 23
    RULE_throwsSpec = 24
    RULE_localsSpec = 25
    RULE_ruleAction = 26
    RULE_ruleModifiers = 27
    RULE_ruleModifier = 28
    RULE_ruleBlock = 29
    RULE_ruleAltList = 30
    RULE_labeledAlt = 31
    RULE_lexerRuleSpec = 32
    RULE_lexerRuleBlock = 33
    RULE_lexerAltList = 34
    RULE_lexerAlt = 35
    RULE_lexerElements = 36
    RULE_lexerElement = 37
    RULE_labeledLexerElement = 38
    RULE_lexerBlock = 39
    RULE_lexerCommands = 40
    RULE_lexerCommand = 41
    RULE_lexerCommandName = 42
    RULE_lexerCommandExpr = 43
    RULE_altList = 44
    RULE_alternative = 45
    RULE_element = 46
    RULE_labeledElement = 47
    RULE_ebnfSuffix = 48
    RULE_lexerAtom = 49
    RULE_atom = 50
    RULE_notSet = 51
    RULE_blockSet = 52
    RULE_setElement = 53
    RULE_block = 54
    RULE_ruleref = 55
    RULE_characterRange = 56
    RULE_terminal = 57
    RULE_elementOptions = 58
    RULE_elementOption = 59
    RULE_identifier = 60

    ruleNames =  [ "grammarSpec", "grammarType", "prequelConstruct", "optionsSpec", 
                   "option", "optionValue", "delegateGrammars", "delegateGrammar", 
                   "tokensSpec", "channelsSpec", "idList", "action", "actionScopeName", 
                   "actionBlock", "argActionBlock", "modeSpec", "rules", 
                   "ruleSpec", "parserRuleSpec", "exceptionGroup", "exceptionHandler", 
                   "finallyClause", "rulePrequel", "ruleReturns", "throwsSpec", 
                   "localsSpec", "ruleAction", "ruleModifiers", "ruleModifier", 
                   "ruleBlock", "ruleAltList", "labeledAlt", "lexerRuleSpec", 
                   "lexerRuleBlock", "lexerAltList", "lexerAlt", "lexerElements", 
                   "lexerElement", "labeledLexerElement", "lexerBlock", 
                   "lexerCommands", "lexerCommand", "lexerCommandName", 
                   "lexerCommandExpr", "altList", "alternative", "element", 
                   "labeledElement", "ebnfSuffix", "lexerAtom", "atom", 
                   "notSet", "blockSet", "setElement", "block", "ruleref", 
                   "characterRange", "terminal", "elementOptions", "elementOption", 
                   "identifier" ]

    EOF = Token.EOF
    TOKEN_REF=1
    RULE_REF=2
    LEXER_CHAR_SET=3
    DOC_COMMENT=4
    HEADER=5
    BLOCK_COMMENT=6
    LINE_COMMENT=7
    INT=8
    STRING_LITERAL=9
    UNTERMINATED_STRING_LITERAL=10
    BEGIN_ARGUMENT=11
    BEGIN_ACTION=12
    OPTIONS=13
    TOKENS=14
    CHANNELS=15
    IMPORT=16
    FRAGMENT=17
    LEXER=18
    PARSER=19
    GRAMMAR=20
    PROTECTED=21
    PUBLIC=22
    PRIVATE=23
    RETURNS=24
    LOCALS=25
    THROWS=26
    CATCH=27
    FINALLY=28
    MODE=29
    COLON=30
    COLONCOLON=31
    COMMA=32
    SEMI=33
    LPAREN=34
    RPAREN=35
    LBRACE=36
    RBRACE=37
    RARROW=38
    LT=39
    GT=40
    ASSIGN=41
    QUESTION=42
    STAR=43
    PLUS_ASSIGN=44
    PLUS=45
    OR=46
    DOLLAR=47
    RANGE=48
    DOT=49
    AT=50
    POUND=51
    NOT=52
    ID=53
    WS=54
    ERRCHAR=55
    END_ARGUMENT=56
    UNTERMINATED_ARGUMENT=57
    ARGUMENT_CONTENT=58
    END_ACTION=59
    UNTERMINATED_ACTION=60
    ACTION_CONTENT=61
    UNTERMINATED_CHAR_SET=62

    def __init__(self, input:TokenStream, output:TextIO = sys.stdout):
        super().__init__(input, output)
        self.checkVersion("4.7")
        self._interp = ParserATNSimulator(self, self.atn, self.decisionsToDFA, self.sharedContextCache)
        self._predicates = None



    class GrammarSpecContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self._DOC_COMMENT = None # Token
            self.docs = list() # of Tokens
            self.gtype = None # GrammarTypeContext
            self.gname = None # IdentifierContext

        def SEMI(self):
            return self.getToken(ANTLRv4Parser.SEMI, 0)

        def rules(self):
            return self.getTypedRuleContext(ANTLRv4Parser.RulesContext,0)


        def EOF(self):
            return self.getToken(ANTLRv4Parser.EOF, 0)

        def grammarType(self):
            return self.getTypedRuleContext(ANTLRv4Parser.GrammarTypeContext,0)


        def identifier(self):
            return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,0)


        def prequelConstruct(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.PrequelConstructContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.PrequelConstructContext,i)


        def modeSpec(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.ModeSpecContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.ModeSpecContext,i)


        def DOC_COMMENT(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.DOC_COMMENT)
            else:
                return self.getToken(ANTLRv4Parser.DOC_COMMENT, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_grammarSpec

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterGrammarSpec" ):
                listener.enterGrammarSpec(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitGrammarSpec" ):
                listener.exitGrammarSpec(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitGrammarSpec" ):
                return visitor.visitGrammarSpec(self)
            else:
                return visitor.visitChildren(self)




    def grammarSpec(self):

        localctx = ANTLRv4Parser.GrammarSpecContext(self, self._ctx, self.state)
        self.enterRule(localctx, 0, self.RULE_grammarSpec)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 125
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.DOC_COMMENT:
                self.state = 122
                localctx._DOC_COMMENT = self.match(ANTLRv4Parser.DOC_COMMENT)
                localctx.docs.append(localctx._DOC_COMMENT)
                self.state = 127
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 128
            localctx.gtype = self.grammarType()
            self.state = 129
            localctx.gname = self.identifier()
            self.state = 130
            self.match(ANTLRv4Parser.SEMI)
            self.state = 134
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while (((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << ANTLRv4Parser.OPTIONS) | (1 << ANTLRv4Parser.TOKENS) | (1 << ANTLRv4Parser.CHANNELS) | (1 << ANTLRv4Parser.IMPORT) | (1 << ANTLRv4Parser.AT))) != 0):
                self.state = 131
                self.prequelConstruct()
                self.state = 136
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 137
            self.rules()
            self.state = 141
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.MODE:
                self.state = 138
                self.modeSpec()
                self.state = 143
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 144
            self.match(ANTLRv4Parser.EOF)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class GrammarTypeContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def LEXER(self):
            return self.getToken(ANTLRv4Parser.LEXER, 0)

        def GRAMMAR(self):
            return self.getToken(ANTLRv4Parser.GRAMMAR, 0)

        def PARSER(self):
            return self.getToken(ANTLRv4Parser.PARSER, 0)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_grammarType

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterGrammarType" ):
                listener.enterGrammarType(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitGrammarType" ):
                listener.exitGrammarType(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitGrammarType" ):
                return visitor.visitGrammarType(self)
            else:
                return visitor.visitChildren(self)




    def grammarType(self):

        localctx = ANTLRv4Parser.GrammarTypeContext(self, self._ctx, self.state)
        self.enterRule(localctx, 2, self.RULE_grammarType)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 151
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [ANTLRv4Parser.LEXER]:
                self.state = 146
                self.match(ANTLRv4Parser.LEXER)
                self.state = 147
                self.match(ANTLRv4Parser.GRAMMAR)
                pass
            elif token in [ANTLRv4Parser.PARSER]:
                self.state = 148
                self.match(ANTLRv4Parser.PARSER)
                self.state = 149
                self.match(ANTLRv4Parser.GRAMMAR)
                pass
            elif token in [ANTLRv4Parser.GRAMMAR]:
                self.state = 150
                self.match(ANTLRv4Parser.GRAMMAR)
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class PrequelConstructContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def optionsSpec(self):
            return self.getTypedRuleContext(ANTLRv4Parser.OptionsSpecContext,0)


        def delegateGrammars(self):
            return self.getTypedRuleContext(ANTLRv4Parser.DelegateGrammarsContext,0)


        def tokensSpec(self):
            return self.getTypedRuleContext(ANTLRv4Parser.TokensSpecContext,0)


        def channelsSpec(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ChannelsSpecContext,0)


        def action(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ActionContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_prequelConstruct

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterPrequelConstruct" ):
                listener.enterPrequelConstruct(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitPrequelConstruct" ):
                listener.exitPrequelConstruct(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitPrequelConstruct" ):
                return visitor.visitPrequelConstruct(self)
            else:
                return visitor.visitChildren(self)




    def prequelConstruct(self):

        localctx = ANTLRv4Parser.PrequelConstructContext(self, self._ctx, self.state)
        self.enterRule(localctx, 4, self.RULE_prequelConstruct)
        try:
            self.state = 158
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [ANTLRv4Parser.OPTIONS]:
                self.enterOuterAlt(localctx, 1)
                self.state = 153
                self.optionsSpec()
                pass
            elif token in [ANTLRv4Parser.IMPORT]:
                self.enterOuterAlt(localctx, 2)
                self.state = 154
                self.delegateGrammars()
                pass
            elif token in [ANTLRv4Parser.TOKENS]:
                self.enterOuterAlt(localctx, 3)
                self.state = 155
                self.tokensSpec()
                pass
            elif token in [ANTLRv4Parser.CHANNELS]:
                self.enterOuterAlt(localctx, 4)
                self.state = 156
                self.channelsSpec()
                pass
            elif token in [ANTLRv4Parser.AT]:
                self.enterOuterAlt(localctx, 5)
                self.state = 157
                self.action()
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class OptionsSpecContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def OPTIONS(self):
            return self.getToken(ANTLRv4Parser.OPTIONS, 0)

        def RBRACE(self):
            return self.getToken(ANTLRv4Parser.RBRACE, 0)

        def option(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.OptionContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.OptionContext,i)


        def SEMI(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.SEMI)
            else:
                return self.getToken(ANTLRv4Parser.SEMI, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_optionsSpec

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterOptionsSpec" ):
                listener.enterOptionsSpec(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitOptionsSpec" ):
                listener.exitOptionsSpec(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitOptionsSpec" ):
                return visitor.visitOptionsSpec(self)
            else:
                return visitor.visitChildren(self)




    def optionsSpec(self):

        localctx = ANTLRv4Parser.OptionsSpecContext(self, self._ctx, self.state)
        self.enterRule(localctx, 6, self.RULE_optionsSpec)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 160
            self.match(ANTLRv4Parser.OPTIONS)
            self.state = 166
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.TOKEN_REF or _la==ANTLRv4Parser.RULE_REF:
                self.state = 161
                self.option()
                self.state = 162
                self.match(ANTLRv4Parser.SEMI)
                self.state = 168
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 169
            self.match(ANTLRv4Parser.RBRACE)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class OptionContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self.name = None # IdentifierContext
            self.value = None # OptionValueContext

        def ASSIGN(self):
            return self.getToken(ANTLRv4Parser.ASSIGN, 0)

        def identifier(self):
            return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,0)


        def optionValue(self):
            return self.getTypedRuleContext(ANTLRv4Parser.OptionValueContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_option

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterOption" ):
                listener.enterOption(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitOption" ):
                listener.exitOption(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitOption" ):
                return visitor.visitOption(self)
            else:
                return visitor.visitChildren(self)




    def option(self):

        localctx = ANTLRv4Parser.OptionContext(self, self._ctx, self.state)
        self.enterRule(localctx, 8, self.RULE_option)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 171
            localctx.name = self.identifier()
            self.state = 172
            self.match(ANTLRv4Parser.ASSIGN)
            self.state = 173
            localctx.value = self.optionValue()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class OptionValueContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_optionValue

     
        def copyFrom(self, ctx:ParserRuleContext):
            super().copyFrom(ctx)



    class StringOptionContext(OptionValueContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.OptionValueContext
            super().__init__(parser)
            self.value = None # Token
            self.copyFrom(ctx)

        def STRING_LITERAL(self):
            return self.getToken(ANTLRv4Parser.STRING_LITERAL, 0)

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterStringOption" ):
                listener.enterStringOption(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitStringOption" ):
                listener.exitStringOption(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitStringOption" ):
                return visitor.visitStringOption(self)
            else:
                return visitor.visitChildren(self)


    class IntOptionContext(OptionValueContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.OptionValueContext
            super().__init__(parser)
            self.value = None # Token
            self.copyFrom(ctx)

        def INT(self):
            return self.getToken(ANTLRv4Parser.INT, 0)

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterIntOption" ):
                listener.enterIntOption(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitIntOption" ):
                listener.exitIntOption(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitIntOption" ):
                return visitor.visitIntOption(self)
            else:
                return visitor.visitChildren(self)


    class ActionOptionContext(OptionValueContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.OptionValueContext
            super().__init__(parser)
            self.value = None # ActionBlockContext
            self.copyFrom(ctx)

        def actionBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ActionBlockContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterActionOption" ):
                listener.enterActionOption(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitActionOption" ):
                listener.exitActionOption(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitActionOption" ):
                return visitor.visitActionOption(self)
            else:
                return visitor.visitChildren(self)


    class PathOptionContext(OptionValueContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.OptionValueContext
            super().__init__(parser)
            self._identifier = None # IdentifierContext
            self.value = list() # of IdentifierContexts
            self.copyFrom(ctx)

        def identifier(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.IdentifierContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,i)

        def DOT(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.DOT)
            else:
                return self.getToken(ANTLRv4Parser.DOT, i)

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterPathOption" ):
                listener.enterPathOption(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitPathOption" ):
                listener.exitPathOption(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitPathOption" ):
                return visitor.visitPathOption(self)
            else:
                return visitor.visitChildren(self)



    def optionValue(self):

        localctx = ANTLRv4Parser.OptionValueContext(self, self._ctx, self.state)
        self.enterRule(localctx, 10, self.RULE_optionValue)
        self._la = 0 # Token type
        try:
            self.state = 186
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [ANTLRv4Parser.TOKEN_REF, ANTLRv4Parser.RULE_REF]:
                localctx = ANTLRv4Parser.PathOptionContext(self, localctx)
                self.enterOuterAlt(localctx, 1)
                self.state = 175
                localctx._identifier = self.identifier()
                localctx.value.append(localctx._identifier)
                self.state = 180
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                while _la==ANTLRv4Parser.DOT:
                    self.state = 176
                    self.match(ANTLRv4Parser.DOT)
                    self.state = 177
                    localctx._identifier = self.identifier()
                    localctx.value.append(localctx._identifier)
                    self.state = 182
                    self._errHandler.sync(self)
                    _la = self._input.LA(1)

                pass
            elif token in [ANTLRv4Parser.STRING_LITERAL]:
                localctx = ANTLRv4Parser.StringOptionContext(self, localctx)
                self.enterOuterAlt(localctx, 2)
                self.state = 183
                localctx.value = self.match(ANTLRv4Parser.STRING_LITERAL)
                pass
            elif token in [ANTLRv4Parser.BEGIN_ACTION]:
                localctx = ANTLRv4Parser.ActionOptionContext(self, localctx)
                self.enterOuterAlt(localctx, 3)
                self.state = 184
                localctx.value = self.actionBlock()
                pass
            elif token in [ANTLRv4Parser.INT]:
                localctx = ANTLRv4Parser.IntOptionContext(self, localctx)
                self.enterOuterAlt(localctx, 4)
                self.state = 185
                localctx.value = self.match(ANTLRv4Parser.INT)
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class DelegateGrammarsContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def IMPORT(self):
            return self.getToken(ANTLRv4Parser.IMPORT, 0)

        def delegateGrammar(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.DelegateGrammarContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.DelegateGrammarContext,i)


        def SEMI(self):
            return self.getToken(ANTLRv4Parser.SEMI, 0)

        def COMMA(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.COMMA)
            else:
                return self.getToken(ANTLRv4Parser.COMMA, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_delegateGrammars

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterDelegateGrammars" ):
                listener.enterDelegateGrammars(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitDelegateGrammars" ):
                listener.exitDelegateGrammars(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitDelegateGrammars" ):
                return visitor.visitDelegateGrammars(self)
            else:
                return visitor.visitChildren(self)




    def delegateGrammars(self):

        localctx = ANTLRv4Parser.DelegateGrammarsContext(self, self._ctx, self.state)
        self.enterRule(localctx, 12, self.RULE_delegateGrammars)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 188
            self.match(ANTLRv4Parser.IMPORT)
            self.state = 189
            self.delegateGrammar()
            self.state = 194
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.COMMA:
                self.state = 190
                self.match(ANTLRv4Parser.COMMA)
                self.state = 191
                self.delegateGrammar()
                self.state = 196
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 197
            self.match(ANTLRv4Parser.SEMI)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class DelegateGrammarContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self.value = None # IdentifierContext

        def identifier(self):
            return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_delegateGrammar

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterDelegateGrammar" ):
                listener.enterDelegateGrammar(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitDelegateGrammar" ):
                listener.exitDelegateGrammar(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitDelegateGrammar" ):
                return visitor.visitDelegateGrammar(self)
            else:
                return visitor.visitChildren(self)




    def delegateGrammar(self):

        localctx = ANTLRv4Parser.DelegateGrammarContext(self, self._ctx, self.state)
        self.enterRule(localctx, 14, self.RULE_delegateGrammar)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 199
            localctx.value = self.identifier()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class TokensSpecContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self.defs = None # IdListContext

        def TOKENS(self):
            return self.getToken(ANTLRv4Parser.TOKENS, 0)

        def RBRACE(self):
            return self.getToken(ANTLRv4Parser.RBRACE, 0)

        def idList(self):
            return self.getTypedRuleContext(ANTLRv4Parser.IdListContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_tokensSpec

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterTokensSpec" ):
                listener.enterTokensSpec(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitTokensSpec" ):
                listener.exitTokensSpec(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitTokensSpec" ):
                return visitor.visitTokensSpec(self)
            else:
                return visitor.visitChildren(self)




    def tokensSpec(self):

        localctx = ANTLRv4Parser.TokensSpecContext(self, self._ctx, self.state)
        self.enterRule(localctx, 16, self.RULE_tokensSpec)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 201
            self.match(ANTLRv4Parser.TOKENS)
            self.state = 203
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==ANTLRv4Parser.TOKEN_REF or _la==ANTLRv4Parser.RULE_REF:
                self.state = 202
                localctx.defs = self.idList()


            self.state = 205
            self.match(ANTLRv4Parser.RBRACE)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class ChannelsSpecContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def CHANNELS(self):
            return self.getToken(ANTLRv4Parser.CHANNELS, 0)

        def RBRACE(self):
            return self.getToken(ANTLRv4Parser.RBRACE, 0)

        def idList(self):
            return self.getTypedRuleContext(ANTLRv4Parser.IdListContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_channelsSpec

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterChannelsSpec" ):
                listener.enterChannelsSpec(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitChannelsSpec" ):
                listener.exitChannelsSpec(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitChannelsSpec" ):
                return visitor.visitChannelsSpec(self)
            else:
                return visitor.visitChildren(self)




    def channelsSpec(self):

        localctx = ANTLRv4Parser.ChannelsSpecContext(self, self._ctx, self.state)
        self.enterRule(localctx, 18, self.RULE_channelsSpec)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 207
            self.match(ANTLRv4Parser.CHANNELS)
            self.state = 209
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==ANTLRv4Parser.TOKEN_REF or _la==ANTLRv4Parser.RULE_REF:
                self.state = 208
                self.idList()


            self.state = 211
            self.match(ANTLRv4Parser.RBRACE)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class IdListContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self._identifier = None # IdentifierContext
            self.defs = list() # of IdentifierContexts

        def identifier(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.IdentifierContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,i)


        def COMMA(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.COMMA)
            else:
                return self.getToken(ANTLRv4Parser.COMMA, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_idList

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterIdList" ):
                listener.enterIdList(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitIdList" ):
                listener.exitIdList(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitIdList" ):
                return visitor.visitIdList(self)
            else:
                return visitor.visitChildren(self)




    def idList(self):

        localctx = ANTLRv4Parser.IdListContext(self, self._ctx, self.state)
        self.enterRule(localctx, 20, self.RULE_idList)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 213
            localctx._identifier = self.identifier()
            localctx.defs.append(localctx._identifier)
            self.state = 218
            self._errHandler.sync(self)
            _alt = self._interp.adaptivePredict(self._input,11,self._ctx)
            while _alt!=2 and _alt!=ATN.INVALID_ALT_NUMBER:
                if _alt==1:
                    self.state = 214
                    self.match(ANTLRv4Parser.COMMA)
                    self.state = 215
                    localctx._identifier = self.identifier()
                    localctx.defs.append(localctx._identifier) 
                self.state = 220
                self._errHandler.sync(self)
                _alt = self._interp.adaptivePredict(self._input,11,self._ctx)

            self.state = 222
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==ANTLRv4Parser.COMMA:
                self.state = 221
                self.match(ANTLRv4Parser.COMMA)


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class ActionContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def AT(self):
            return self.getToken(ANTLRv4Parser.AT, 0)

        def identifier(self):
            return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,0)


        def actionBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ActionBlockContext,0)


        def actionScopeName(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ActionScopeNameContext,0)


        def COLONCOLON(self):
            return self.getToken(ANTLRv4Parser.COLONCOLON, 0)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_action

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterAction" ):
                listener.enterAction(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitAction" ):
                listener.exitAction(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitAction" ):
                return visitor.visitAction(self)
            else:
                return visitor.visitChildren(self)




    def action(self):

        localctx = ANTLRv4Parser.ActionContext(self, self._ctx, self.state)
        self.enterRule(localctx, 22, self.RULE_action)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 224
            self.match(ANTLRv4Parser.AT)
            self.state = 228
            self._errHandler.sync(self)
            la_ = self._interp.adaptivePredict(self._input,13,self._ctx)
            if la_ == 1:
                self.state = 225
                self.actionScopeName()
                self.state = 226
                self.match(ANTLRv4Parser.COLONCOLON)


            self.state = 230
            self.identifier()
            self.state = 231
            self.actionBlock()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class ActionScopeNameContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def identifier(self):
            return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,0)


        def LEXER(self):
            return self.getToken(ANTLRv4Parser.LEXER, 0)

        def PARSER(self):
            return self.getToken(ANTLRv4Parser.PARSER, 0)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_actionScopeName

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterActionScopeName" ):
                listener.enterActionScopeName(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitActionScopeName" ):
                listener.exitActionScopeName(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitActionScopeName" ):
                return visitor.visitActionScopeName(self)
            else:
                return visitor.visitChildren(self)




    def actionScopeName(self):

        localctx = ANTLRv4Parser.ActionScopeNameContext(self, self._ctx, self.state)
        self.enterRule(localctx, 24, self.RULE_actionScopeName)
        try:
            self.state = 236
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [ANTLRv4Parser.TOKEN_REF, ANTLRv4Parser.RULE_REF]:
                self.enterOuterAlt(localctx, 1)
                self.state = 233
                self.identifier()
                pass
            elif token in [ANTLRv4Parser.LEXER]:
                self.enterOuterAlt(localctx, 2)
                self.state = 234
                self.match(ANTLRv4Parser.LEXER)
                pass
            elif token in [ANTLRv4Parser.PARSER]:
                self.enterOuterAlt(localctx, 3)
                self.state = 235
                self.match(ANTLRv4Parser.PARSER)
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class ActionBlockContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def BEGIN_ACTION(self):
            return self.getToken(ANTLRv4Parser.BEGIN_ACTION, 0)

        def END_ACTION(self):
            return self.getToken(ANTLRv4Parser.END_ACTION, 0)

        def ACTION_CONTENT(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.ACTION_CONTENT)
            else:
                return self.getToken(ANTLRv4Parser.ACTION_CONTENT, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_actionBlock

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterActionBlock" ):
                listener.enterActionBlock(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitActionBlock" ):
                listener.exitActionBlock(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitActionBlock" ):
                return visitor.visitActionBlock(self)
            else:
                return visitor.visitChildren(self)




    def actionBlock(self):

        localctx = ANTLRv4Parser.ActionBlockContext(self, self._ctx, self.state)
        self.enterRule(localctx, 26, self.RULE_actionBlock)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 238
            self.match(ANTLRv4Parser.BEGIN_ACTION)
            self.state = 242
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.ACTION_CONTENT:
                self.state = 239
                self.match(ANTLRv4Parser.ACTION_CONTENT)
                self.state = 244
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 245
            self.match(ANTLRv4Parser.END_ACTION)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class ArgActionBlockContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def BEGIN_ARGUMENT(self):
            return self.getToken(ANTLRv4Parser.BEGIN_ARGUMENT, 0)

        def END_ARGUMENT(self):
            return self.getToken(ANTLRv4Parser.END_ARGUMENT, 0)

        def ARGUMENT_CONTENT(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.ARGUMENT_CONTENT)
            else:
                return self.getToken(ANTLRv4Parser.ARGUMENT_CONTENT, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_argActionBlock

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterArgActionBlock" ):
                listener.enterArgActionBlock(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitArgActionBlock" ):
                listener.exitArgActionBlock(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitArgActionBlock" ):
                return visitor.visitArgActionBlock(self)
            else:
                return visitor.visitChildren(self)




    def argActionBlock(self):

        localctx = ANTLRv4Parser.ArgActionBlockContext(self, self._ctx, self.state)
        self.enterRule(localctx, 28, self.RULE_argActionBlock)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 247
            self.match(ANTLRv4Parser.BEGIN_ARGUMENT)
            self.state = 251
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.ARGUMENT_CONTENT:
                self.state = 248
                self.match(ANTLRv4Parser.ARGUMENT_CONTENT)
                self.state = 253
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 254
            self.match(ANTLRv4Parser.END_ARGUMENT)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class ModeSpecContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def MODE(self):
            return self.getToken(ANTLRv4Parser.MODE, 0)

        def identifier(self):
            return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,0)


        def SEMI(self):
            return self.getToken(ANTLRv4Parser.SEMI, 0)

        def lexerRuleSpec(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.LexerRuleSpecContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.LexerRuleSpecContext,i)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_modeSpec

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterModeSpec" ):
                listener.enterModeSpec(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitModeSpec" ):
                listener.exitModeSpec(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitModeSpec" ):
                return visitor.visitModeSpec(self)
            else:
                return visitor.visitChildren(self)




    def modeSpec(self):

        localctx = ANTLRv4Parser.ModeSpecContext(self, self._ctx, self.state)
        self.enterRule(localctx, 30, self.RULE_modeSpec)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 256
            self.match(ANTLRv4Parser.MODE)
            self.state = 257
            self.identifier()
            self.state = 258
            self.match(ANTLRv4Parser.SEMI)
            self.state = 262
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while (((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << ANTLRv4Parser.TOKEN_REF) | (1 << ANTLRv4Parser.DOC_COMMENT) | (1 << ANTLRv4Parser.FRAGMENT))) != 0):
                self.state = 259
                self.lexerRuleSpec()
                self.state = 264
                self._errHandler.sync(self)
                _la = self._input.LA(1)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class RulesContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def ruleSpec(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.RuleSpecContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.RuleSpecContext,i)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_rules

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterRules" ):
                listener.enterRules(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitRules" ):
                listener.exitRules(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitRules" ):
                return visitor.visitRules(self)
            else:
                return visitor.visitChildren(self)




    def rules(self):

        localctx = ANTLRv4Parser.RulesContext(self, self._ctx, self.state)
        self.enterRule(localctx, 32, self.RULE_rules)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 268
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while (((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << ANTLRv4Parser.TOKEN_REF) | (1 << ANTLRv4Parser.RULE_REF) | (1 << ANTLRv4Parser.DOC_COMMENT) | (1 << ANTLRv4Parser.HEADER) | (1 << ANTLRv4Parser.FRAGMENT) | (1 << ANTLRv4Parser.PROTECTED) | (1 << ANTLRv4Parser.PUBLIC) | (1 << ANTLRv4Parser.PRIVATE))) != 0):
                self.state = 265
                self.ruleSpec()
                self.state = 270
                self._errHandler.sync(self)
                _la = self._input.LA(1)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class RuleSpecContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self._HEADER = None # Token
            self.headers = list() # of Tokens

        def parserRuleSpec(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ParserRuleSpecContext,0)


        def lexerRuleSpec(self):
            return self.getTypedRuleContext(ANTLRv4Parser.LexerRuleSpecContext,0)


        def HEADER(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.HEADER)
            else:
                return self.getToken(ANTLRv4Parser.HEADER, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_ruleSpec

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterRuleSpec" ):
                listener.enterRuleSpec(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitRuleSpec" ):
                listener.exitRuleSpec(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitRuleSpec" ):
                return visitor.visitRuleSpec(self)
            else:
                return visitor.visitChildren(self)




    def ruleSpec(self):

        localctx = ANTLRv4Parser.RuleSpecContext(self, self._ctx, self.state)
        self.enterRule(localctx, 34, self.RULE_ruleSpec)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 274
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.HEADER:
                self.state = 271
                localctx._HEADER = self.match(ANTLRv4Parser.HEADER)
                localctx.headers.append(localctx._HEADER)
                self.state = 276
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 279
            self._errHandler.sync(self)
            la_ = self._interp.adaptivePredict(self._input,20,self._ctx)
            if la_ == 1:
                self.state = 277
                self.parserRuleSpec()
                pass

            elif la_ == 2:
                self.state = 278
                self.lexerRuleSpec()
                pass


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class ParserRuleSpecContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self._DOC_COMMENT = None # Token
            self.docs = list() # of Tokens
            self.name = None # Token

        def COLON(self):
            return self.getToken(ANTLRv4Parser.COLON, 0)

        def ruleBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.RuleBlockContext,0)


        def SEMI(self):
            return self.getToken(ANTLRv4Parser.SEMI, 0)

        def exceptionGroup(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ExceptionGroupContext,0)


        def RULE_REF(self):
            return self.getToken(ANTLRv4Parser.RULE_REF, 0)

        def ruleModifiers(self):
            return self.getTypedRuleContext(ANTLRv4Parser.RuleModifiersContext,0)


        def argActionBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ArgActionBlockContext,0)


        def ruleReturns(self):
            return self.getTypedRuleContext(ANTLRv4Parser.RuleReturnsContext,0)


        def throwsSpec(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ThrowsSpecContext,0)


        def localsSpec(self):
            return self.getTypedRuleContext(ANTLRv4Parser.LocalsSpecContext,0)


        def rulePrequel(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.RulePrequelContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.RulePrequelContext,i)


        def DOC_COMMENT(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.DOC_COMMENT)
            else:
                return self.getToken(ANTLRv4Parser.DOC_COMMENT, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_parserRuleSpec

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterParserRuleSpec" ):
                listener.enterParserRuleSpec(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitParserRuleSpec" ):
                listener.exitParserRuleSpec(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitParserRuleSpec" ):
                return visitor.visitParserRuleSpec(self)
            else:
                return visitor.visitChildren(self)




    def parserRuleSpec(self):

        localctx = ANTLRv4Parser.ParserRuleSpecContext(self, self._ctx, self.state)
        self.enterRule(localctx, 36, self.RULE_parserRuleSpec)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 284
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.DOC_COMMENT:
                self.state = 281
                localctx._DOC_COMMENT = self.match(ANTLRv4Parser.DOC_COMMENT)
                localctx.docs.append(localctx._DOC_COMMENT)
                self.state = 286
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 288
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if (((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << ANTLRv4Parser.FRAGMENT) | (1 << ANTLRv4Parser.PROTECTED) | (1 << ANTLRv4Parser.PUBLIC) | (1 << ANTLRv4Parser.PRIVATE))) != 0):
                self.state = 287
                self.ruleModifiers()


            self.state = 290
            localctx.name = self.match(ANTLRv4Parser.RULE_REF)
            self.state = 292
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==ANTLRv4Parser.BEGIN_ARGUMENT:
                self.state = 291
                self.argActionBlock()


            self.state = 295
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==ANTLRv4Parser.RETURNS:
                self.state = 294
                self.ruleReturns()


            self.state = 298
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==ANTLRv4Parser.THROWS:
                self.state = 297
                self.throwsSpec()


            self.state = 301
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==ANTLRv4Parser.LOCALS:
                self.state = 300
                self.localsSpec()


            self.state = 306
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.OPTIONS or _la==ANTLRv4Parser.AT:
                self.state = 303
                self.rulePrequel()
                self.state = 308
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 309
            self.match(ANTLRv4Parser.COLON)
            self.state = 310
            self.ruleBlock()
            self.state = 311
            self.match(ANTLRv4Parser.SEMI)
            self.state = 312
            self.exceptionGroup()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class ExceptionGroupContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def exceptionHandler(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.ExceptionHandlerContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.ExceptionHandlerContext,i)


        def finallyClause(self):
            return self.getTypedRuleContext(ANTLRv4Parser.FinallyClauseContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_exceptionGroup

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterExceptionGroup" ):
                listener.enterExceptionGroup(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitExceptionGroup" ):
                listener.exitExceptionGroup(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitExceptionGroup" ):
                return visitor.visitExceptionGroup(self)
            else:
                return visitor.visitChildren(self)




    def exceptionGroup(self):

        localctx = ANTLRv4Parser.ExceptionGroupContext(self, self._ctx, self.state)
        self.enterRule(localctx, 38, self.RULE_exceptionGroup)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 317
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.CATCH:
                self.state = 314
                self.exceptionHandler()
                self.state = 319
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 321
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==ANTLRv4Parser.FINALLY:
                self.state = 320
                self.finallyClause()


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class ExceptionHandlerContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def CATCH(self):
            return self.getToken(ANTLRv4Parser.CATCH, 0)

        def argActionBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ArgActionBlockContext,0)


        def actionBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ActionBlockContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_exceptionHandler

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterExceptionHandler" ):
                listener.enterExceptionHandler(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitExceptionHandler" ):
                listener.exitExceptionHandler(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitExceptionHandler" ):
                return visitor.visitExceptionHandler(self)
            else:
                return visitor.visitChildren(self)




    def exceptionHandler(self):

        localctx = ANTLRv4Parser.ExceptionHandlerContext(self, self._ctx, self.state)
        self.enterRule(localctx, 40, self.RULE_exceptionHandler)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 323
            self.match(ANTLRv4Parser.CATCH)
            self.state = 324
            self.argActionBlock()
            self.state = 325
            self.actionBlock()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class FinallyClauseContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def FINALLY(self):
            return self.getToken(ANTLRv4Parser.FINALLY, 0)

        def actionBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ActionBlockContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_finallyClause

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterFinallyClause" ):
                listener.enterFinallyClause(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitFinallyClause" ):
                listener.exitFinallyClause(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitFinallyClause" ):
                return visitor.visitFinallyClause(self)
            else:
                return visitor.visitChildren(self)




    def finallyClause(self):

        localctx = ANTLRv4Parser.FinallyClauseContext(self, self._ctx, self.state)
        self.enterRule(localctx, 42, self.RULE_finallyClause)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 327
            self.match(ANTLRv4Parser.FINALLY)
            self.state = 328
            self.actionBlock()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class RulePrequelContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def optionsSpec(self):
            return self.getTypedRuleContext(ANTLRv4Parser.OptionsSpecContext,0)


        def ruleAction(self):
            return self.getTypedRuleContext(ANTLRv4Parser.RuleActionContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_rulePrequel

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterRulePrequel" ):
                listener.enterRulePrequel(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitRulePrequel" ):
                listener.exitRulePrequel(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitRulePrequel" ):
                return visitor.visitRulePrequel(self)
            else:
                return visitor.visitChildren(self)




    def rulePrequel(self):

        localctx = ANTLRv4Parser.RulePrequelContext(self, self._ctx, self.state)
        self.enterRule(localctx, 44, self.RULE_rulePrequel)
        try:
            self.state = 332
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [ANTLRv4Parser.OPTIONS]:
                self.enterOuterAlt(localctx, 1)
                self.state = 330
                self.optionsSpec()
                pass
            elif token in [ANTLRv4Parser.AT]:
                self.enterOuterAlt(localctx, 2)
                self.state = 331
                self.ruleAction()
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class RuleReturnsContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def RETURNS(self):
            return self.getToken(ANTLRv4Parser.RETURNS, 0)

        def argActionBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ArgActionBlockContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_ruleReturns

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterRuleReturns" ):
                listener.enterRuleReturns(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitRuleReturns" ):
                listener.exitRuleReturns(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitRuleReturns" ):
                return visitor.visitRuleReturns(self)
            else:
                return visitor.visitChildren(self)




    def ruleReturns(self):

        localctx = ANTLRv4Parser.RuleReturnsContext(self, self._ctx, self.state)
        self.enterRule(localctx, 46, self.RULE_ruleReturns)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 334
            self.match(ANTLRv4Parser.RETURNS)
            self.state = 335
            self.argActionBlock()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class ThrowsSpecContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def THROWS(self):
            return self.getToken(ANTLRv4Parser.THROWS, 0)

        def identifier(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.IdentifierContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,i)


        def COMMA(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.COMMA)
            else:
                return self.getToken(ANTLRv4Parser.COMMA, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_throwsSpec

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterThrowsSpec" ):
                listener.enterThrowsSpec(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitThrowsSpec" ):
                listener.exitThrowsSpec(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitThrowsSpec" ):
                return visitor.visitThrowsSpec(self)
            else:
                return visitor.visitChildren(self)




    def throwsSpec(self):

        localctx = ANTLRv4Parser.ThrowsSpecContext(self, self._ctx, self.state)
        self.enterRule(localctx, 48, self.RULE_throwsSpec)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 337
            self.match(ANTLRv4Parser.THROWS)
            self.state = 338
            self.identifier()
            self.state = 343
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.COMMA:
                self.state = 339
                self.match(ANTLRv4Parser.COMMA)
                self.state = 340
                self.identifier()
                self.state = 345
                self._errHandler.sync(self)
                _la = self._input.LA(1)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LocalsSpecContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def LOCALS(self):
            return self.getToken(ANTLRv4Parser.LOCALS, 0)

        def argActionBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ArgActionBlockContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_localsSpec

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLocalsSpec" ):
                listener.enterLocalsSpec(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLocalsSpec" ):
                listener.exitLocalsSpec(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLocalsSpec" ):
                return visitor.visitLocalsSpec(self)
            else:
                return visitor.visitChildren(self)




    def localsSpec(self):

        localctx = ANTLRv4Parser.LocalsSpecContext(self, self._ctx, self.state)
        self.enterRule(localctx, 50, self.RULE_localsSpec)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 346
            self.match(ANTLRv4Parser.LOCALS)
            self.state = 347
            self.argActionBlock()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class RuleActionContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def AT(self):
            return self.getToken(ANTLRv4Parser.AT, 0)

        def identifier(self):
            return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,0)


        def actionBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ActionBlockContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_ruleAction

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterRuleAction" ):
                listener.enterRuleAction(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitRuleAction" ):
                listener.exitRuleAction(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitRuleAction" ):
                return visitor.visitRuleAction(self)
            else:
                return visitor.visitChildren(self)




    def ruleAction(self):

        localctx = ANTLRv4Parser.RuleActionContext(self, self._ctx, self.state)
        self.enterRule(localctx, 52, self.RULE_ruleAction)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 349
            self.match(ANTLRv4Parser.AT)
            self.state = 350
            self.identifier()
            self.state = 351
            self.actionBlock()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class RuleModifiersContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def ruleModifier(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.RuleModifierContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.RuleModifierContext,i)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_ruleModifiers

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterRuleModifiers" ):
                listener.enterRuleModifiers(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitRuleModifiers" ):
                listener.exitRuleModifiers(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitRuleModifiers" ):
                return visitor.visitRuleModifiers(self)
            else:
                return visitor.visitChildren(self)




    def ruleModifiers(self):

        localctx = ANTLRv4Parser.RuleModifiersContext(self, self._ctx, self.state)
        self.enterRule(localctx, 54, self.RULE_ruleModifiers)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 354 
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while True:
                self.state = 353
                self.ruleModifier()
                self.state = 356 
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if not ((((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << ANTLRv4Parser.FRAGMENT) | (1 << ANTLRv4Parser.PROTECTED) | (1 << ANTLRv4Parser.PUBLIC) | (1 << ANTLRv4Parser.PRIVATE))) != 0)):
                    break

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class RuleModifierContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def PUBLIC(self):
            return self.getToken(ANTLRv4Parser.PUBLIC, 0)

        def PRIVATE(self):
            return self.getToken(ANTLRv4Parser.PRIVATE, 0)

        def PROTECTED(self):
            return self.getToken(ANTLRv4Parser.PROTECTED, 0)

        def FRAGMENT(self):
            return self.getToken(ANTLRv4Parser.FRAGMENT, 0)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_ruleModifier

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterRuleModifier" ):
                listener.enterRuleModifier(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitRuleModifier" ):
                listener.exitRuleModifier(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitRuleModifier" ):
                return visitor.visitRuleModifier(self)
            else:
                return visitor.visitChildren(self)




    def ruleModifier(self):

        localctx = ANTLRv4Parser.RuleModifierContext(self, self._ctx, self.state)
        self.enterRule(localctx, 56, self.RULE_ruleModifier)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 358
            _la = self._input.LA(1)
            if not((((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << ANTLRv4Parser.FRAGMENT) | (1 << ANTLRv4Parser.PROTECTED) | (1 << ANTLRv4Parser.PUBLIC) | (1 << ANTLRv4Parser.PRIVATE))) != 0)):
                self._errHandler.recoverInline(self)
            else:
                self._errHandler.reportMatch(self)
                self.consume()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class RuleBlockContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def ruleAltList(self):
            return self.getTypedRuleContext(ANTLRv4Parser.RuleAltListContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_ruleBlock

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterRuleBlock" ):
                listener.enterRuleBlock(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitRuleBlock" ):
                listener.exitRuleBlock(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitRuleBlock" ):
                return visitor.visitRuleBlock(self)
            else:
                return visitor.visitChildren(self)




    def ruleBlock(self):

        localctx = ANTLRv4Parser.RuleBlockContext(self, self._ctx, self.state)
        self.enterRule(localctx, 58, self.RULE_ruleBlock)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 360
            self.ruleAltList()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class RuleAltListContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self._labeledAlt = None # LabeledAltContext
            self.alts = list() # of LabeledAltContexts

        def labeledAlt(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.LabeledAltContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.LabeledAltContext,i)


        def OR(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.OR)
            else:
                return self.getToken(ANTLRv4Parser.OR, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_ruleAltList

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterRuleAltList" ):
                listener.enterRuleAltList(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitRuleAltList" ):
                listener.exitRuleAltList(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitRuleAltList" ):
                return visitor.visitRuleAltList(self)
            else:
                return visitor.visitChildren(self)




    def ruleAltList(self):

        localctx = ANTLRv4Parser.RuleAltListContext(self, self._ctx, self.state)
        self.enterRule(localctx, 60, self.RULE_ruleAltList)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 362
            localctx._labeledAlt = self.labeledAlt()
            localctx.alts.append(localctx._labeledAlt)
            self.state = 367
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.OR:
                self.state = 363
                self.match(ANTLRv4Parser.OR)
                self.state = 364
                localctx._labeledAlt = self.labeledAlt()
                localctx.alts.append(localctx._labeledAlt)
                self.state = 369
                self._errHandler.sync(self)
                _la = self._input.LA(1)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LabeledAltContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def alternative(self):
            return self.getTypedRuleContext(ANTLRv4Parser.AlternativeContext,0)


        def POUND(self):
            return self.getToken(ANTLRv4Parser.POUND, 0)

        def identifier(self):
            return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_labeledAlt

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLabeledAlt" ):
                listener.enterLabeledAlt(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLabeledAlt" ):
                listener.exitLabeledAlt(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLabeledAlt" ):
                return visitor.visitLabeledAlt(self)
            else:
                return visitor.visitChildren(self)




    def labeledAlt(self):

        localctx = ANTLRv4Parser.LabeledAltContext(self, self._ctx, self.state)
        self.enterRule(localctx, 62, self.RULE_labeledAlt)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 370
            self.alternative()
            self.state = 373
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==ANTLRv4Parser.POUND:
                self.state = 371
                self.match(ANTLRv4Parser.POUND)
                self.state = 372
                self.identifier()


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LexerRuleSpecContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self._DOC_COMMENT = None # Token
            self.docs = list() # of Tokens
            self.frag = None # Token
            self.name = None # Token

        def COLON(self):
            return self.getToken(ANTLRv4Parser.COLON, 0)

        def lexerRuleBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.LexerRuleBlockContext,0)


        def SEMI(self):
            return self.getToken(ANTLRv4Parser.SEMI, 0)

        def TOKEN_REF(self):
            return self.getToken(ANTLRv4Parser.TOKEN_REF, 0)

        def DOC_COMMENT(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.DOC_COMMENT)
            else:
                return self.getToken(ANTLRv4Parser.DOC_COMMENT, i)

        def FRAGMENT(self):
            return self.getToken(ANTLRv4Parser.FRAGMENT, 0)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_lexerRuleSpec

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerRuleSpec" ):
                listener.enterLexerRuleSpec(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerRuleSpec" ):
                listener.exitLexerRuleSpec(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerRuleSpec" ):
                return visitor.visitLexerRuleSpec(self)
            else:
                return visitor.visitChildren(self)




    def lexerRuleSpec(self):

        localctx = ANTLRv4Parser.LexerRuleSpecContext(self, self._ctx, self.state)
        self.enterRule(localctx, 64, self.RULE_lexerRuleSpec)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 378
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.DOC_COMMENT:
                self.state = 375
                localctx._DOC_COMMENT = self.match(ANTLRv4Parser.DOC_COMMENT)
                localctx.docs.append(localctx._DOC_COMMENT)
                self.state = 380
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 382
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==ANTLRv4Parser.FRAGMENT:
                self.state = 381
                localctx.frag = self.match(ANTLRv4Parser.FRAGMENT)


            self.state = 384
            localctx.name = self.match(ANTLRv4Parser.TOKEN_REF)
            self.state = 385
            self.match(ANTLRv4Parser.COLON)
            self.state = 386
            self.lexerRuleBlock()
            self.state = 387
            self.match(ANTLRv4Parser.SEMI)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LexerRuleBlockContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def lexerAltList(self):
            return self.getTypedRuleContext(ANTLRv4Parser.LexerAltListContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_lexerRuleBlock

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerRuleBlock" ):
                listener.enterLexerRuleBlock(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerRuleBlock" ):
                listener.exitLexerRuleBlock(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerRuleBlock" ):
                return visitor.visitLexerRuleBlock(self)
            else:
                return visitor.visitChildren(self)




    def lexerRuleBlock(self):

        localctx = ANTLRv4Parser.LexerRuleBlockContext(self, self._ctx, self.state)
        self.enterRule(localctx, 66, self.RULE_lexerRuleBlock)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 389
            self.lexerAltList()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LexerAltListContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self._lexerAlt = None # LexerAltContext
            self.alts = list() # of LexerAltContexts

        def lexerAlt(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.LexerAltContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.LexerAltContext,i)


        def OR(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.OR)
            else:
                return self.getToken(ANTLRv4Parser.OR, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_lexerAltList

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerAltList" ):
                listener.enterLexerAltList(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerAltList" ):
                listener.exitLexerAltList(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerAltList" ):
                return visitor.visitLexerAltList(self)
            else:
                return visitor.visitChildren(self)




    def lexerAltList(self):

        localctx = ANTLRv4Parser.LexerAltListContext(self, self._ctx, self.state)
        self.enterRule(localctx, 68, self.RULE_lexerAltList)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 391
            localctx._lexerAlt = self.lexerAlt()
            localctx.alts.append(localctx._lexerAlt)
            self.state = 396
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.OR:
                self.state = 392
                self.match(ANTLRv4Parser.OR)
                self.state = 393
                localctx._lexerAlt = self.lexerAlt()
                localctx.alts.append(localctx._lexerAlt)
                self.state = 398
                self._errHandler.sync(self)
                _la = self._input.LA(1)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LexerAltContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def lexerElements(self):
            return self.getTypedRuleContext(ANTLRv4Parser.LexerElementsContext,0)


        def lexerCommands(self):
            return self.getTypedRuleContext(ANTLRv4Parser.LexerCommandsContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_lexerAlt

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerAlt" ):
                listener.enterLexerAlt(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerAlt" ):
                listener.exitLexerAlt(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerAlt" ):
                return visitor.visitLexerAlt(self)
            else:
                return visitor.visitChildren(self)




    def lexerAlt(self):

        localctx = ANTLRv4Parser.LexerAltContext(self, self._ctx, self.state)
        self.enterRule(localctx, 70, self.RULE_lexerAlt)
        self._la = 0 # Token type
        try:
            self.state = 404
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [ANTLRv4Parser.TOKEN_REF, ANTLRv4Parser.RULE_REF, ANTLRv4Parser.LEXER_CHAR_SET, ANTLRv4Parser.DOC_COMMENT, ANTLRv4Parser.STRING_LITERAL, ANTLRv4Parser.BEGIN_ACTION, ANTLRv4Parser.LPAREN, ANTLRv4Parser.DOT, ANTLRv4Parser.NOT]:
                self.enterOuterAlt(localctx, 1)
                self.state = 399
                self.lexerElements()
                self.state = 401
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if _la==ANTLRv4Parser.RARROW:
                    self.state = 400
                    self.lexerCommands()


                pass
            elif token in [ANTLRv4Parser.SEMI, ANTLRv4Parser.RPAREN, ANTLRv4Parser.OR]:
                self.enterOuterAlt(localctx, 2)

                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LexerElementsContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self._lexerElement = None # LexerElementContext
            self.elements = list() # of LexerElementContexts

        def lexerElement(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.LexerElementContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.LexerElementContext,i)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_lexerElements

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerElements" ):
                listener.enterLexerElements(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerElements" ):
                listener.exitLexerElements(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerElements" ):
                return visitor.visitLexerElements(self)
            else:
                return visitor.visitChildren(self)




    def lexerElements(self):

        localctx = ANTLRv4Parser.LexerElementsContext(self, self._ctx, self.state)
        self.enterRule(localctx, 72, self.RULE_lexerElements)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 407 
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while True:
                self.state = 406
                localctx._lexerElement = self.lexerElement()
                localctx.elements.append(localctx._lexerElement)
                self.state = 409 
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if not ((((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << ANTLRv4Parser.TOKEN_REF) | (1 << ANTLRv4Parser.RULE_REF) | (1 << ANTLRv4Parser.LEXER_CHAR_SET) | (1 << ANTLRv4Parser.DOC_COMMENT) | (1 << ANTLRv4Parser.STRING_LITERAL) | (1 << ANTLRv4Parser.BEGIN_ACTION) | (1 << ANTLRv4Parser.LPAREN) | (1 << ANTLRv4Parser.DOT) | (1 << ANTLRv4Parser.NOT))) != 0)):
                    break

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LexerElementContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_lexerElement

     
        def copyFrom(self, ctx:ParserRuleContext):
            super().copyFrom(ctx)



    class LexerElementLabeledContext(LexerElementContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.LexerElementContext
            super().__init__(parser)
            self.value = None # LabeledLexerElementContext
            self.suffix = None # EbnfSuffixContext
            self.copyFrom(ctx)

        def labeledLexerElement(self):
            return self.getTypedRuleContext(ANTLRv4Parser.LabeledLexerElementContext,0)

        def ebnfSuffix(self):
            return self.getTypedRuleContext(ANTLRv4Parser.EbnfSuffixContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerElementLabeled" ):
                listener.enterLexerElementLabeled(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerElementLabeled" ):
                listener.exitLexerElementLabeled(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerElementLabeled" ):
                return visitor.visitLexerElementLabeled(self)
            else:
                return visitor.visitChildren(self)


    class LexerElementBlockContext(LexerElementContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.LexerElementContext
            super().__init__(parser)
            self.value = None # LexerBlockContext
            self.suffix = None # EbnfSuffixContext
            self.copyFrom(ctx)

        def lexerBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.LexerBlockContext,0)

        def ebnfSuffix(self):
            return self.getTypedRuleContext(ANTLRv4Parser.EbnfSuffixContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerElementBlock" ):
                listener.enterLexerElementBlock(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerElementBlock" ):
                listener.exitLexerElementBlock(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerElementBlock" ):
                return visitor.visitLexerElementBlock(self)
            else:
                return visitor.visitChildren(self)


    class LexerElementActionContext(LexerElementContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.LexerElementContext
            super().__init__(parser)
            self.copyFrom(ctx)

        def actionBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ActionBlockContext,0)

        def QUESTION(self):
            return self.getToken(ANTLRv4Parser.QUESTION, 0)

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerElementAction" ):
                listener.enterLexerElementAction(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerElementAction" ):
                listener.exitLexerElementAction(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerElementAction" ):
                return visitor.visitLexerElementAction(self)
            else:
                return visitor.visitChildren(self)


    class LexerElementAtomContext(LexerElementContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.LexerElementContext
            super().__init__(parser)
            self.value = None # LexerAtomContext
            self.suffix = None # EbnfSuffixContext
            self.copyFrom(ctx)

        def lexerAtom(self):
            return self.getTypedRuleContext(ANTLRv4Parser.LexerAtomContext,0)

        def ebnfSuffix(self):
            return self.getTypedRuleContext(ANTLRv4Parser.EbnfSuffixContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerElementAtom" ):
                listener.enterLexerElementAtom(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerElementAtom" ):
                listener.exitLexerElementAtom(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerElementAtom" ):
                return visitor.visitLexerElementAtom(self)
            else:
                return visitor.visitChildren(self)



    def lexerElement(self):

        localctx = ANTLRv4Parser.LexerElementContext(self, self._ctx, self.state)
        self.enterRule(localctx, 74, self.RULE_lexerElement)
        self._la = 0 # Token type
        try:
            self.state = 427
            self._errHandler.sync(self)
            la_ = self._interp.adaptivePredict(self._input,45,self._ctx)
            if la_ == 1:
                localctx = ANTLRv4Parser.LexerElementLabeledContext(self, localctx)
                self.enterOuterAlt(localctx, 1)
                self.state = 411
                localctx.value = self.labeledLexerElement()
                self.state = 413
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if (((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << ANTLRv4Parser.QUESTION) | (1 << ANTLRv4Parser.STAR) | (1 << ANTLRv4Parser.PLUS))) != 0):
                    self.state = 412
                    localctx.suffix = self.ebnfSuffix()


                pass

            elif la_ == 2:
                localctx = ANTLRv4Parser.LexerElementAtomContext(self, localctx)
                self.enterOuterAlt(localctx, 2)
                self.state = 415
                localctx.value = self.lexerAtom()
                self.state = 417
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if (((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << ANTLRv4Parser.QUESTION) | (1 << ANTLRv4Parser.STAR) | (1 << ANTLRv4Parser.PLUS))) != 0):
                    self.state = 416
                    localctx.suffix = self.ebnfSuffix()


                pass

            elif la_ == 3:
                localctx = ANTLRv4Parser.LexerElementBlockContext(self, localctx)
                self.enterOuterAlt(localctx, 3)
                self.state = 419
                localctx.value = self.lexerBlock()
                self.state = 421
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if (((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << ANTLRv4Parser.QUESTION) | (1 << ANTLRv4Parser.STAR) | (1 << ANTLRv4Parser.PLUS))) != 0):
                    self.state = 420
                    localctx.suffix = self.ebnfSuffix()


                pass

            elif la_ == 4:
                localctx = ANTLRv4Parser.LexerElementActionContext(self, localctx)
                self.enterOuterAlt(localctx, 4)
                self.state = 423
                self.actionBlock()
                self.state = 425
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if _la==ANTLRv4Parser.QUESTION:
                    self.state = 424
                    self.match(ANTLRv4Parser.QUESTION)


                pass


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LabeledLexerElementContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def identifier(self):
            return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,0)


        def ASSIGN(self):
            return self.getToken(ANTLRv4Parser.ASSIGN, 0)

        def PLUS_ASSIGN(self):
            return self.getToken(ANTLRv4Parser.PLUS_ASSIGN, 0)

        def lexerAtom(self):
            return self.getTypedRuleContext(ANTLRv4Parser.LexerAtomContext,0)


        def lexerBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.LexerBlockContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_labeledLexerElement

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLabeledLexerElement" ):
                listener.enterLabeledLexerElement(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLabeledLexerElement" ):
                listener.exitLabeledLexerElement(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLabeledLexerElement" ):
                return visitor.visitLabeledLexerElement(self)
            else:
                return visitor.visitChildren(self)




    def labeledLexerElement(self):

        localctx = ANTLRv4Parser.LabeledLexerElementContext(self, self._ctx, self.state)
        self.enterRule(localctx, 76, self.RULE_labeledLexerElement)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 429
            self.identifier()
            self.state = 430
            _la = self._input.LA(1)
            if not(_la==ANTLRv4Parser.ASSIGN or _la==ANTLRv4Parser.PLUS_ASSIGN):
                self._errHandler.recoverInline(self)
            else:
                self._errHandler.reportMatch(self)
                self.consume()
            self.state = 433
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [ANTLRv4Parser.TOKEN_REF, ANTLRv4Parser.LEXER_CHAR_SET, ANTLRv4Parser.DOC_COMMENT, ANTLRv4Parser.STRING_LITERAL, ANTLRv4Parser.DOT, ANTLRv4Parser.NOT]:
                self.state = 431
                self.lexerAtom()
                pass
            elif token in [ANTLRv4Parser.LPAREN]:
                self.state = 432
                self.lexerBlock()
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LexerBlockContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def LPAREN(self):
            return self.getToken(ANTLRv4Parser.LPAREN, 0)

        def lexerAltList(self):
            return self.getTypedRuleContext(ANTLRv4Parser.LexerAltListContext,0)


        def RPAREN(self):
            return self.getToken(ANTLRv4Parser.RPAREN, 0)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_lexerBlock

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerBlock" ):
                listener.enterLexerBlock(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerBlock" ):
                listener.exitLexerBlock(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerBlock" ):
                return visitor.visitLexerBlock(self)
            else:
                return visitor.visitChildren(self)




    def lexerBlock(self):

        localctx = ANTLRv4Parser.LexerBlockContext(self, self._ctx, self.state)
        self.enterRule(localctx, 78, self.RULE_lexerBlock)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 435
            self.match(ANTLRv4Parser.LPAREN)
            self.state = 436
            self.lexerAltList()
            self.state = 437
            self.match(ANTLRv4Parser.RPAREN)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LexerCommandsContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def RARROW(self):
            return self.getToken(ANTLRv4Parser.RARROW, 0)

        def lexerCommand(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.LexerCommandContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.LexerCommandContext,i)


        def COMMA(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.COMMA)
            else:
                return self.getToken(ANTLRv4Parser.COMMA, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_lexerCommands

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerCommands" ):
                listener.enterLexerCommands(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerCommands" ):
                listener.exitLexerCommands(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerCommands" ):
                return visitor.visitLexerCommands(self)
            else:
                return visitor.visitChildren(self)




    def lexerCommands(self):

        localctx = ANTLRv4Parser.LexerCommandsContext(self, self._ctx, self.state)
        self.enterRule(localctx, 80, self.RULE_lexerCommands)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 439
            self.match(ANTLRv4Parser.RARROW)
            self.state = 440
            self.lexerCommand()
            self.state = 445
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.COMMA:
                self.state = 441
                self.match(ANTLRv4Parser.COMMA)
                self.state = 442
                self.lexerCommand()
                self.state = 447
                self._errHandler.sync(self)
                _la = self._input.LA(1)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LexerCommandContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def lexerCommandName(self):
            return self.getTypedRuleContext(ANTLRv4Parser.LexerCommandNameContext,0)


        def LPAREN(self):
            return self.getToken(ANTLRv4Parser.LPAREN, 0)

        def lexerCommandExpr(self):
            return self.getTypedRuleContext(ANTLRv4Parser.LexerCommandExprContext,0)


        def RPAREN(self):
            return self.getToken(ANTLRv4Parser.RPAREN, 0)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_lexerCommand

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerCommand" ):
                listener.enterLexerCommand(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerCommand" ):
                listener.exitLexerCommand(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerCommand" ):
                return visitor.visitLexerCommand(self)
            else:
                return visitor.visitChildren(self)




    def lexerCommand(self):

        localctx = ANTLRv4Parser.LexerCommandContext(self, self._ctx, self.state)
        self.enterRule(localctx, 82, self.RULE_lexerCommand)
        try:
            self.state = 454
            self._errHandler.sync(self)
            la_ = self._interp.adaptivePredict(self._input,48,self._ctx)
            if la_ == 1:
                self.enterOuterAlt(localctx, 1)
                self.state = 448
                self.lexerCommandName()
                self.state = 449
                self.match(ANTLRv4Parser.LPAREN)
                self.state = 450
                self.lexerCommandExpr()
                self.state = 451
                self.match(ANTLRv4Parser.RPAREN)
                pass

            elif la_ == 2:
                self.enterOuterAlt(localctx, 2)
                self.state = 453
                self.lexerCommandName()
                pass


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LexerCommandNameContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def identifier(self):
            return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,0)


        def MODE(self):
            return self.getToken(ANTLRv4Parser.MODE, 0)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_lexerCommandName

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerCommandName" ):
                listener.enterLexerCommandName(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerCommandName" ):
                listener.exitLexerCommandName(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerCommandName" ):
                return visitor.visitLexerCommandName(self)
            else:
                return visitor.visitChildren(self)




    def lexerCommandName(self):

        localctx = ANTLRv4Parser.LexerCommandNameContext(self, self._ctx, self.state)
        self.enterRule(localctx, 84, self.RULE_lexerCommandName)
        try:
            self.state = 458
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [ANTLRv4Parser.TOKEN_REF, ANTLRv4Parser.RULE_REF]:
                self.enterOuterAlt(localctx, 1)
                self.state = 456
                self.identifier()
                pass
            elif token in [ANTLRv4Parser.MODE]:
                self.enterOuterAlt(localctx, 2)
                self.state = 457
                self.match(ANTLRv4Parser.MODE)
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LexerCommandExprContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def identifier(self):
            return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,0)


        def INT(self):
            return self.getToken(ANTLRv4Parser.INT, 0)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_lexerCommandExpr

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerCommandExpr" ):
                listener.enterLexerCommandExpr(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerCommandExpr" ):
                listener.exitLexerCommandExpr(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerCommandExpr" ):
                return visitor.visitLexerCommandExpr(self)
            else:
                return visitor.visitChildren(self)




    def lexerCommandExpr(self):

        localctx = ANTLRv4Parser.LexerCommandExprContext(self, self._ctx, self.state)
        self.enterRule(localctx, 86, self.RULE_lexerCommandExpr)
        try:
            self.state = 462
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [ANTLRv4Parser.TOKEN_REF, ANTLRv4Parser.RULE_REF]:
                self.enterOuterAlt(localctx, 1)
                self.state = 460
                self.identifier()
                pass
            elif token in [ANTLRv4Parser.INT]:
                self.enterOuterAlt(localctx, 2)
                self.state = 461
                self.match(ANTLRv4Parser.INT)
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class AltListContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self._alternative = None # AlternativeContext
            self.alts = list() # of AlternativeContexts

        def alternative(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.AlternativeContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.AlternativeContext,i)


        def OR(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.OR)
            else:
                return self.getToken(ANTLRv4Parser.OR, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_altList

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterAltList" ):
                listener.enterAltList(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitAltList" ):
                listener.exitAltList(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitAltList" ):
                return visitor.visitAltList(self)
            else:
                return visitor.visitChildren(self)




    def altList(self):

        localctx = ANTLRv4Parser.AltListContext(self, self._ctx, self.state)
        self.enterRule(localctx, 88, self.RULE_altList)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 464
            localctx._alternative = self.alternative()
            localctx.alts.append(localctx._alternative)
            self.state = 469
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.OR:
                self.state = 465
                self.match(ANTLRv4Parser.OR)
                self.state = 466
                localctx._alternative = self.alternative()
                localctx.alts.append(localctx._alternative)
                self.state = 471
                self._errHandler.sync(self)
                _la = self._input.LA(1)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class AlternativeContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self._element = None # ElementContext
            self.elements = list() # of ElementContexts

        def elementOptions(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ElementOptionsContext,0)


        def element(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.ElementContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.ElementContext,i)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_alternative

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterAlternative" ):
                listener.enterAlternative(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitAlternative" ):
                listener.exitAlternative(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitAlternative" ):
                return visitor.visitAlternative(self)
            else:
                return visitor.visitChildren(self)




    def alternative(self):

        localctx = ANTLRv4Parser.AlternativeContext(self, self._ctx, self.state)
        self.enterRule(localctx, 90, self.RULE_alternative)
        self._la = 0 # Token type
        try:
            self.state = 481
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [ANTLRv4Parser.TOKEN_REF, ANTLRv4Parser.RULE_REF, ANTLRv4Parser.DOC_COMMENT, ANTLRv4Parser.STRING_LITERAL, ANTLRv4Parser.BEGIN_ACTION, ANTLRv4Parser.LPAREN, ANTLRv4Parser.LT, ANTLRv4Parser.DOT, ANTLRv4Parser.NOT]:
                self.enterOuterAlt(localctx, 1)
                self.state = 473
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if _la==ANTLRv4Parser.LT:
                    self.state = 472
                    self.elementOptions()


                self.state = 476 
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                while True:
                    self.state = 475
                    localctx._element = self.element()
                    localctx.elements.append(localctx._element)
                    self.state = 478 
                    self._errHandler.sync(self)
                    _la = self._input.LA(1)
                    if not ((((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << ANTLRv4Parser.TOKEN_REF) | (1 << ANTLRv4Parser.RULE_REF) | (1 << ANTLRv4Parser.DOC_COMMENT) | (1 << ANTLRv4Parser.STRING_LITERAL) | (1 << ANTLRv4Parser.BEGIN_ACTION) | (1 << ANTLRv4Parser.LPAREN) | (1 << ANTLRv4Parser.DOT) | (1 << ANTLRv4Parser.NOT))) != 0)):
                        break

                pass
            elif token in [ANTLRv4Parser.SEMI, ANTLRv4Parser.RPAREN, ANTLRv4Parser.OR, ANTLRv4Parser.POUND]:
                self.enterOuterAlt(localctx, 2)

                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class ElementContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_element

     
        def copyFrom(self, ctx:ParserRuleContext):
            super().copyFrom(ctx)



    class ParserElementLabeledContext(ElementContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.ElementContext
            super().__init__(parser)
            self.value = None # LabeledElementContext
            self.suffix = None # EbnfSuffixContext
            self.copyFrom(ctx)

        def labeledElement(self):
            return self.getTypedRuleContext(ANTLRv4Parser.LabeledElementContext,0)

        def ebnfSuffix(self):
            return self.getTypedRuleContext(ANTLRv4Parser.EbnfSuffixContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterParserElementLabeled" ):
                listener.enterParserElementLabeled(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitParserElementLabeled" ):
                listener.exitParserElementLabeled(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitParserElementLabeled" ):
                return visitor.visitParserElementLabeled(self)
            else:
                return visitor.visitChildren(self)


    class ParserElementBlockContext(ElementContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.ElementContext
            super().__init__(parser)
            self.value = None # BlockContext
            self.suffix = None # EbnfSuffixContext
            self.copyFrom(ctx)

        def block(self):
            return self.getTypedRuleContext(ANTLRv4Parser.BlockContext,0)

        def ebnfSuffix(self):
            return self.getTypedRuleContext(ANTLRv4Parser.EbnfSuffixContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterParserElementBlock" ):
                listener.enterParserElementBlock(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitParserElementBlock" ):
                listener.exitParserElementBlock(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitParserElementBlock" ):
                return visitor.visitParserElementBlock(self)
            else:
                return visitor.visitChildren(self)


    class ParserElementAtomContext(ElementContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.ElementContext
            super().__init__(parser)
            self.value = None # AtomContext
            self.suffix = None # EbnfSuffixContext
            self.copyFrom(ctx)

        def atom(self):
            return self.getTypedRuleContext(ANTLRv4Parser.AtomContext,0)

        def ebnfSuffix(self):
            return self.getTypedRuleContext(ANTLRv4Parser.EbnfSuffixContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterParserElementAtom" ):
                listener.enterParserElementAtom(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitParserElementAtom" ):
                listener.exitParserElementAtom(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitParserElementAtom" ):
                return visitor.visitParserElementAtom(self)
            else:
                return visitor.visitChildren(self)


    class ParserInlineDocContext(ElementContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.ElementContext
            super().__init__(parser)
            self.value = None # Token
            self.copyFrom(ctx)

        def DOC_COMMENT(self):
            return self.getToken(ANTLRv4Parser.DOC_COMMENT, 0)

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterParserInlineDoc" ):
                listener.enterParserInlineDoc(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitParserInlineDoc" ):
                listener.exitParserInlineDoc(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitParserInlineDoc" ):
                return visitor.visitParserInlineDoc(self)
            else:
                return visitor.visitChildren(self)


    class ParserElementActionContext(ElementContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.ElementContext
            super().__init__(parser)
            self.copyFrom(ctx)

        def actionBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ActionBlockContext,0)

        def QUESTION(self):
            return self.getToken(ANTLRv4Parser.QUESTION, 0)

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterParserElementAction" ):
                listener.enterParserElementAction(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitParserElementAction" ):
                listener.exitParserElementAction(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitParserElementAction" ):
                return visitor.visitParserElementAction(self)
            else:
                return visitor.visitChildren(self)



    def element(self):

        localctx = ANTLRv4Parser.ElementContext(self, self._ctx, self.state)
        self.enterRule(localctx, 92, self.RULE_element)
        self._la = 0 # Token type
        try:
            self.state = 500
            self._errHandler.sync(self)
            la_ = self._interp.adaptivePredict(self._input,59,self._ctx)
            if la_ == 1:
                localctx = ANTLRv4Parser.ParserElementLabeledContext(self, localctx)
                self.enterOuterAlt(localctx, 1)
                self.state = 483
                localctx.value = self.labeledElement()
                self.state = 485
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if (((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << ANTLRv4Parser.QUESTION) | (1 << ANTLRv4Parser.STAR) | (1 << ANTLRv4Parser.PLUS))) != 0):
                    self.state = 484
                    localctx.suffix = self.ebnfSuffix()


                pass

            elif la_ == 2:
                localctx = ANTLRv4Parser.ParserElementAtomContext(self, localctx)
                self.enterOuterAlt(localctx, 2)
                self.state = 487
                localctx.value = self.atom()
                self.state = 489
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if (((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << ANTLRv4Parser.QUESTION) | (1 << ANTLRv4Parser.STAR) | (1 << ANTLRv4Parser.PLUS))) != 0):
                    self.state = 488
                    localctx.suffix = self.ebnfSuffix()


                pass

            elif la_ == 3:
                localctx = ANTLRv4Parser.ParserElementBlockContext(self, localctx)
                self.enterOuterAlt(localctx, 3)
                self.state = 491
                localctx.value = self.block()
                self.state = 493
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if (((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << ANTLRv4Parser.QUESTION) | (1 << ANTLRv4Parser.STAR) | (1 << ANTLRv4Parser.PLUS))) != 0):
                    self.state = 492
                    localctx.suffix = self.ebnfSuffix()


                pass

            elif la_ == 4:
                localctx = ANTLRv4Parser.ParserElementActionContext(self, localctx)
                self.enterOuterAlt(localctx, 4)
                self.state = 495
                self.actionBlock()
                self.state = 497
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if _la==ANTLRv4Parser.QUESTION:
                    self.state = 496
                    self.match(ANTLRv4Parser.QUESTION)


                pass

            elif la_ == 5:
                localctx = ANTLRv4Parser.ParserInlineDocContext(self, localctx)
                self.enterOuterAlt(localctx, 5)
                self.state = 499
                localctx.value = self.match(ANTLRv4Parser.DOC_COMMENT)
                pass


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LabeledElementContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def identifier(self):
            return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,0)


        def ASSIGN(self):
            return self.getToken(ANTLRv4Parser.ASSIGN, 0)

        def PLUS_ASSIGN(self):
            return self.getToken(ANTLRv4Parser.PLUS_ASSIGN, 0)

        def atom(self):
            return self.getTypedRuleContext(ANTLRv4Parser.AtomContext,0)


        def block(self):
            return self.getTypedRuleContext(ANTLRv4Parser.BlockContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_labeledElement

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLabeledElement" ):
                listener.enterLabeledElement(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLabeledElement" ):
                listener.exitLabeledElement(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLabeledElement" ):
                return visitor.visitLabeledElement(self)
            else:
                return visitor.visitChildren(self)




    def labeledElement(self):

        localctx = ANTLRv4Parser.LabeledElementContext(self, self._ctx, self.state)
        self.enterRule(localctx, 94, self.RULE_labeledElement)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 502
            self.identifier()
            self.state = 503
            _la = self._input.LA(1)
            if not(_la==ANTLRv4Parser.ASSIGN or _la==ANTLRv4Parser.PLUS_ASSIGN):
                self._errHandler.recoverInline(self)
            else:
                self._errHandler.reportMatch(self)
                self.consume()
            self.state = 506
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [ANTLRv4Parser.TOKEN_REF, ANTLRv4Parser.RULE_REF, ANTLRv4Parser.STRING_LITERAL, ANTLRv4Parser.DOT, ANTLRv4Parser.NOT]:
                self.state = 504
                self.atom()
                pass
            elif token in [ANTLRv4Parser.LPAREN]:
                self.state = 505
                self.block()
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class EbnfSuffixContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def QUESTION(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.QUESTION)
            else:
                return self.getToken(ANTLRv4Parser.QUESTION, i)

        def STAR(self):
            return self.getToken(ANTLRv4Parser.STAR, 0)

        def PLUS(self):
            return self.getToken(ANTLRv4Parser.PLUS, 0)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_ebnfSuffix

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterEbnfSuffix" ):
                listener.enterEbnfSuffix(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitEbnfSuffix" ):
                listener.exitEbnfSuffix(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitEbnfSuffix" ):
                return visitor.visitEbnfSuffix(self)
            else:
                return visitor.visitChildren(self)




    def ebnfSuffix(self):

        localctx = ANTLRv4Parser.EbnfSuffixContext(self, self._ctx, self.state)
        self.enterRule(localctx, 96, self.RULE_ebnfSuffix)
        self._la = 0 # Token type
        try:
            self.state = 520
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [ANTLRv4Parser.QUESTION]:
                self.enterOuterAlt(localctx, 1)
                self.state = 508
                self.match(ANTLRv4Parser.QUESTION)
                self.state = 510
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if _la==ANTLRv4Parser.QUESTION:
                    self.state = 509
                    self.match(ANTLRv4Parser.QUESTION)


                pass
            elif token in [ANTLRv4Parser.STAR]:
                self.enterOuterAlt(localctx, 2)
                self.state = 512
                self.match(ANTLRv4Parser.STAR)
                self.state = 514
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if _la==ANTLRv4Parser.QUESTION:
                    self.state = 513
                    self.match(ANTLRv4Parser.QUESTION)


                pass
            elif token in [ANTLRv4Parser.PLUS]:
                self.enterOuterAlt(localctx, 3)
                self.state = 516
                self.match(ANTLRv4Parser.PLUS)
                self.state = 518
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if _la==ANTLRv4Parser.QUESTION:
                    self.state = 517
                    self.match(ANTLRv4Parser.QUESTION)


                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class LexerAtomContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_lexerAtom

     
        def copyFrom(self, ctx:ParserRuleContext):
            super().copyFrom(ctx)



    class LexerAtomNotContext(LexerAtomContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.LexerAtomContext
            super().__init__(parser)
            self.copyFrom(ctx)

        def notSet(self):
            return self.getTypedRuleContext(ANTLRv4Parser.NotSetContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerAtomNot" ):
                listener.enterLexerAtomNot(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerAtomNot" ):
                listener.exitLexerAtomNot(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerAtomNot" ):
                return visitor.visitLexerAtomNot(self)
            else:
                return visitor.visitChildren(self)


    class LexerAtomRangeContext(LexerAtomContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.LexerAtomContext
            super().__init__(parser)
            self.copyFrom(ctx)

        def characterRange(self):
            return self.getTypedRuleContext(ANTLRv4Parser.CharacterRangeContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerAtomRange" ):
                listener.enterLexerAtomRange(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerAtomRange" ):
                listener.exitLexerAtomRange(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerAtomRange" ):
                return visitor.visitLexerAtomRange(self)
            else:
                return visitor.visitChildren(self)


    class LexerAtomCharSetContext(LexerAtomContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.LexerAtomContext
            super().__init__(parser)
            self.value = None # Token
            self.copyFrom(ctx)

        def LEXER_CHAR_SET(self):
            return self.getToken(ANTLRv4Parser.LEXER_CHAR_SET, 0)

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerAtomCharSet" ):
                listener.enterLexerAtomCharSet(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerAtomCharSet" ):
                listener.exitLexerAtomCharSet(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerAtomCharSet" ):
                return visitor.visitLexerAtomCharSet(self)
            else:
                return visitor.visitChildren(self)


    class LexerAtomWildcardContext(LexerAtomContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.LexerAtomContext
            super().__init__(parser)
            self.copyFrom(ctx)

        def DOT(self):
            return self.getToken(ANTLRv4Parser.DOT, 0)
        def elementOptions(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ElementOptionsContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerAtomWildcard" ):
                listener.enterLexerAtomWildcard(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerAtomWildcard" ):
                listener.exitLexerAtomWildcard(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerAtomWildcard" ):
                return visitor.visitLexerAtomWildcard(self)
            else:
                return visitor.visitChildren(self)


    class LexerAtomTerminalContext(LexerAtomContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.LexerAtomContext
            super().__init__(parser)
            self.copyFrom(ctx)

        def terminal(self):
            return self.getTypedRuleContext(ANTLRv4Parser.TerminalContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerAtomTerminal" ):
                listener.enterLexerAtomTerminal(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerAtomTerminal" ):
                listener.exitLexerAtomTerminal(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerAtomTerminal" ):
                return visitor.visitLexerAtomTerminal(self)
            else:
                return visitor.visitChildren(self)


    class LexerAtomDocContext(LexerAtomContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.LexerAtomContext
            super().__init__(parser)
            self.value = None # Token
            self.copyFrom(ctx)

        def DOC_COMMENT(self):
            return self.getToken(ANTLRv4Parser.DOC_COMMENT, 0)

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLexerAtomDoc" ):
                listener.enterLexerAtomDoc(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLexerAtomDoc" ):
                listener.exitLexerAtomDoc(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLexerAtomDoc" ):
                return visitor.visitLexerAtomDoc(self)
            else:
                return visitor.visitChildren(self)



    def lexerAtom(self):

        localctx = ANTLRv4Parser.LexerAtomContext(self, self._ctx, self.state)
        self.enterRule(localctx, 98, self.RULE_lexerAtom)
        self._la = 0 # Token type
        try:
            self.state = 531
            self._errHandler.sync(self)
            la_ = self._interp.adaptivePredict(self._input,66,self._ctx)
            if la_ == 1:
                localctx = ANTLRv4Parser.LexerAtomRangeContext(self, localctx)
                self.enterOuterAlt(localctx, 1)
                self.state = 522
                self.characterRange()
                pass

            elif la_ == 2:
                localctx = ANTLRv4Parser.LexerAtomTerminalContext(self, localctx)
                self.enterOuterAlt(localctx, 2)
                self.state = 523
                self.terminal()
                pass

            elif la_ == 3:
                localctx = ANTLRv4Parser.LexerAtomNotContext(self, localctx)
                self.enterOuterAlt(localctx, 3)
                self.state = 524
                self.notSet()
                pass

            elif la_ == 4:
                localctx = ANTLRv4Parser.LexerAtomCharSetContext(self, localctx)
                self.enterOuterAlt(localctx, 4)
                self.state = 525
                localctx.value = self.match(ANTLRv4Parser.LEXER_CHAR_SET)
                pass

            elif la_ == 5:
                localctx = ANTLRv4Parser.LexerAtomWildcardContext(self, localctx)
                self.enterOuterAlt(localctx, 5)
                self.state = 526
                self.match(ANTLRv4Parser.DOT)
                self.state = 528
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if _la==ANTLRv4Parser.LT:
                    self.state = 527
                    self.elementOptions()


                pass

            elif la_ == 6:
                localctx = ANTLRv4Parser.LexerAtomDocContext(self, localctx)
                self.enterOuterAlt(localctx, 6)
                self.state = 530
                localctx.value = self.match(ANTLRv4Parser.DOC_COMMENT)
                pass


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class AtomContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_atom

     
        def copyFrom(self, ctx:ParserRuleContext):
            super().copyFrom(ctx)



    class AtomTerminalContext(AtomContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.AtomContext
            super().__init__(parser)
            self.copyFrom(ctx)

        def terminal(self):
            return self.getTypedRuleContext(ANTLRv4Parser.TerminalContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterAtomTerminal" ):
                listener.enterAtomTerminal(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitAtomTerminal" ):
                listener.exitAtomTerminal(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitAtomTerminal" ):
                return visitor.visitAtomTerminal(self)
            else:
                return visitor.visitChildren(self)


    class AtomWildcardContext(AtomContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.AtomContext
            super().__init__(parser)
            self.copyFrom(ctx)

        def DOT(self):
            return self.getToken(ANTLRv4Parser.DOT, 0)
        def elementOptions(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ElementOptionsContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterAtomWildcard" ):
                listener.enterAtomWildcard(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitAtomWildcard" ):
                listener.exitAtomWildcard(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitAtomWildcard" ):
                return visitor.visitAtomWildcard(self)
            else:
                return visitor.visitChildren(self)


    class AtomRuleRefContext(AtomContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.AtomContext
            super().__init__(parser)
            self.copyFrom(ctx)

        def ruleref(self):
            return self.getTypedRuleContext(ANTLRv4Parser.RulerefContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterAtomRuleRef" ):
                listener.enterAtomRuleRef(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitAtomRuleRef" ):
                listener.exitAtomRuleRef(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitAtomRuleRef" ):
                return visitor.visitAtomRuleRef(self)
            else:
                return visitor.visitChildren(self)


    class AtomNotContext(AtomContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.AtomContext
            super().__init__(parser)
            self.copyFrom(ctx)

        def notSet(self):
            return self.getTypedRuleContext(ANTLRv4Parser.NotSetContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterAtomNot" ):
                listener.enterAtomNot(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitAtomNot" ):
                listener.exitAtomNot(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitAtomNot" ):
                return visitor.visitAtomNot(self)
            else:
                return visitor.visitChildren(self)



    def atom(self):

        localctx = ANTLRv4Parser.AtomContext(self, self._ctx, self.state)
        self.enterRule(localctx, 100, self.RULE_atom)
        self._la = 0 # Token type
        try:
            self.state = 540
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [ANTLRv4Parser.TOKEN_REF, ANTLRv4Parser.STRING_LITERAL]:
                localctx = ANTLRv4Parser.AtomTerminalContext(self, localctx)
                self.enterOuterAlt(localctx, 1)
                self.state = 533
                self.terminal()
                pass
            elif token in [ANTLRv4Parser.RULE_REF]:
                localctx = ANTLRv4Parser.AtomRuleRefContext(self, localctx)
                self.enterOuterAlt(localctx, 2)
                self.state = 534
                self.ruleref()
                pass
            elif token in [ANTLRv4Parser.NOT]:
                localctx = ANTLRv4Parser.AtomNotContext(self, localctx)
                self.enterOuterAlt(localctx, 3)
                self.state = 535
                self.notSet()
                pass
            elif token in [ANTLRv4Parser.DOT]:
                localctx = ANTLRv4Parser.AtomWildcardContext(self, localctx)
                self.enterOuterAlt(localctx, 4)
                self.state = 536
                self.match(ANTLRv4Parser.DOT)
                self.state = 538
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if _la==ANTLRv4Parser.LT:
                    self.state = 537
                    self.elementOptions()


                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class NotSetContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_notSet

     
        def copyFrom(self, ctx:ParserRuleContext):
            super().copyFrom(ctx)



    class NotBlockContext(NotSetContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.NotSetContext
            super().__init__(parser)
            self.value = None # BlockSetContext
            self.copyFrom(ctx)

        def NOT(self):
            return self.getToken(ANTLRv4Parser.NOT, 0)
        def blockSet(self):
            return self.getTypedRuleContext(ANTLRv4Parser.BlockSetContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterNotBlock" ):
                listener.enterNotBlock(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitNotBlock" ):
                listener.exitNotBlock(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitNotBlock" ):
                return visitor.visitNotBlock(self)
            else:
                return visitor.visitChildren(self)


    class NotElementContext(NotSetContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.NotSetContext
            super().__init__(parser)
            self.value = None # SetElementContext
            self.copyFrom(ctx)

        def NOT(self):
            return self.getToken(ANTLRv4Parser.NOT, 0)
        def setElement(self):
            return self.getTypedRuleContext(ANTLRv4Parser.SetElementContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterNotElement" ):
                listener.enterNotElement(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitNotElement" ):
                listener.exitNotElement(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitNotElement" ):
                return visitor.visitNotElement(self)
            else:
                return visitor.visitChildren(self)



    def notSet(self):

        localctx = ANTLRv4Parser.NotSetContext(self, self._ctx, self.state)
        self.enterRule(localctx, 102, self.RULE_notSet)
        try:
            self.state = 546
            self._errHandler.sync(self)
            la_ = self._interp.adaptivePredict(self._input,69,self._ctx)
            if la_ == 1:
                localctx = ANTLRv4Parser.NotElementContext(self, localctx)
                self.enterOuterAlt(localctx, 1)
                self.state = 542
                self.match(ANTLRv4Parser.NOT)
                self.state = 543
                localctx.value = self.setElement()
                pass

            elif la_ == 2:
                localctx = ANTLRv4Parser.NotBlockContext(self, localctx)
                self.enterOuterAlt(localctx, 2)
                self.state = 544
                self.match(ANTLRv4Parser.NOT)
                self.state = 545
                localctx.value = self.blockSet()
                pass


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class BlockSetContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self._setElement = None # SetElementContext
            self.elements = list() # of SetElementContexts

        def LPAREN(self):
            return self.getToken(ANTLRv4Parser.LPAREN, 0)

        def RPAREN(self):
            return self.getToken(ANTLRv4Parser.RPAREN, 0)

        def setElement(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.SetElementContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.SetElementContext,i)


        def OR(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.OR)
            else:
                return self.getToken(ANTLRv4Parser.OR, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_blockSet

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterBlockSet" ):
                listener.enterBlockSet(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitBlockSet" ):
                listener.exitBlockSet(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitBlockSet" ):
                return visitor.visitBlockSet(self)
            else:
                return visitor.visitChildren(self)




    def blockSet(self):

        localctx = ANTLRv4Parser.BlockSetContext(self, self._ctx, self.state)
        self.enterRule(localctx, 104, self.RULE_blockSet)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 548
            self.match(ANTLRv4Parser.LPAREN)
            self.state = 549
            localctx._setElement = self.setElement()
            localctx.elements.append(localctx._setElement)
            self.state = 554
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.OR:
                self.state = 550
                self.match(ANTLRv4Parser.OR)
                self.state = 551
                localctx._setElement = self.setElement()
                localctx.elements.append(localctx._setElement)
                self.state = 556
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 557
            self.match(ANTLRv4Parser.RPAREN)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class SetElementContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_setElement

     
        def copyFrom(self, ctx:ParserRuleContext):
            super().copyFrom(ctx)



    class SetElementRefContext(SetElementContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.SetElementContext
            super().__init__(parser)
            self.value = None # Token
            self.copyFrom(ctx)

        def TOKEN_REF(self):
            return self.getToken(ANTLRv4Parser.TOKEN_REF, 0)
        def elementOptions(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ElementOptionsContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterSetElementRef" ):
                listener.enterSetElementRef(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitSetElementRef" ):
                listener.exitSetElementRef(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitSetElementRef" ):
                return visitor.visitSetElementRef(self)
            else:
                return visitor.visitChildren(self)


    class SetElementRangeContext(SetElementContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.SetElementContext
            super().__init__(parser)
            self.copyFrom(ctx)

        def characterRange(self):
            return self.getTypedRuleContext(ANTLRv4Parser.CharacterRangeContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterSetElementRange" ):
                listener.enterSetElementRange(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitSetElementRange" ):
                listener.exitSetElementRange(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitSetElementRange" ):
                return visitor.visitSetElementRange(self)
            else:
                return visitor.visitChildren(self)


    class SetElementLitContext(SetElementContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.SetElementContext
            super().__init__(parser)
            self.value = None # Token
            self.copyFrom(ctx)

        def STRING_LITERAL(self):
            return self.getToken(ANTLRv4Parser.STRING_LITERAL, 0)
        def elementOptions(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ElementOptionsContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterSetElementLit" ):
                listener.enterSetElementLit(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitSetElementLit" ):
                listener.exitSetElementLit(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitSetElementLit" ):
                return visitor.visitSetElementLit(self)
            else:
                return visitor.visitChildren(self)


    class SetElementCharSetContext(SetElementContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.SetElementContext
            super().__init__(parser)
            self.value = None # Token
            self.copyFrom(ctx)

        def LEXER_CHAR_SET(self):
            return self.getToken(ANTLRv4Parser.LEXER_CHAR_SET, 0)

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterSetElementCharSet" ):
                listener.enterSetElementCharSet(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitSetElementCharSet" ):
                listener.exitSetElementCharSet(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitSetElementCharSet" ):
                return visitor.visitSetElementCharSet(self)
            else:
                return visitor.visitChildren(self)



    def setElement(self):

        localctx = ANTLRv4Parser.SetElementContext(self, self._ctx, self.state)
        self.enterRule(localctx, 106, self.RULE_setElement)
        self._la = 0 # Token type
        try:
            self.state = 569
            self._errHandler.sync(self)
            la_ = self._interp.adaptivePredict(self._input,73,self._ctx)
            if la_ == 1:
                localctx = ANTLRv4Parser.SetElementRefContext(self, localctx)
                self.enterOuterAlt(localctx, 1)
                self.state = 559
                localctx.value = self.match(ANTLRv4Parser.TOKEN_REF)
                self.state = 561
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if _la==ANTLRv4Parser.LT:
                    self.state = 560
                    self.elementOptions()


                pass

            elif la_ == 2:
                localctx = ANTLRv4Parser.SetElementLitContext(self, localctx)
                self.enterOuterAlt(localctx, 2)
                self.state = 563
                localctx.value = self.match(ANTLRv4Parser.STRING_LITERAL)
                self.state = 565
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if _la==ANTLRv4Parser.LT:
                    self.state = 564
                    self.elementOptions()


                pass

            elif la_ == 3:
                localctx = ANTLRv4Parser.SetElementRangeContext(self, localctx)
                self.enterOuterAlt(localctx, 3)
                self.state = 567
                self.characterRange()
                pass

            elif la_ == 4:
                localctx = ANTLRv4Parser.SetElementCharSetContext(self, localctx)
                self.enterOuterAlt(localctx, 4)
                self.state = 568
                localctx.value = self.match(ANTLRv4Parser.LEXER_CHAR_SET)
                pass


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class BlockContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def LPAREN(self):
            return self.getToken(ANTLRv4Parser.LPAREN, 0)

        def altList(self):
            return self.getTypedRuleContext(ANTLRv4Parser.AltListContext,0)


        def RPAREN(self):
            return self.getToken(ANTLRv4Parser.RPAREN, 0)

        def COLON(self):
            return self.getToken(ANTLRv4Parser.COLON, 0)

        def optionsSpec(self):
            return self.getTypedRuleContext(ANTLRv4Parser.OptionsSpecContext,0)


        def ruleAction(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.RuleActionContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.RuleActionContext,i)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_block

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterBlock" ):
                listener.enterBlock(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitBlock" ):
                listener.exitBlock(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitBlock" ):
                return visitor.visitBlock(self)
            else:
                return visitor.visitChildren(self)




    def block(self):

        localctx = ANTLRv4Parser.BlockContext(self, self._ctx, self.state)
        self.enterRule(localctx, 108, self.RULE_block)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 571
            self.match(ANTLRv4Parser.LPAREN)
            self.state = 582
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if (((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << ANTLRv4Parser.OPTIONS) | (1 << ANTLRv4Parser.COLON) | (1 << ANTLRv4Parser.AT))) != 0):
                self.state = 573
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if _la==ANTLRv4Parser.OPTIONS:
                    self.state = 572
                    self.optionsSpec()


                self.state = 578
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                while _la==ANTLRv4Parser.AT:
                    self.state = 575
                    self.ruleAction()
                    self.state = 580
                    self._errHandler.sync(self)
                    _la = self._input.LA(1)

                self.state = 581
                self.match(ANTLRv4Parser.COLON)


            self.state = 584
            self.altList()
            self.state = 585
            self.match(ANTLRv4Parser.RPAREN)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class RulerefContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self.value = None # Token

        def RULE_REF(self):
            return self.getToken(ANTLRv4Parser.RULE_REF, 0)

        def argActionBlock(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ArgActionBlockContext,0)


        def elementOptions(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ElementOptionsContext,0)


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_ruleref

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterRuleref" ):
                listener.enterRuleref(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitRuleref" ):
                listener.exitRuleref(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitRuleref" ):
                return visitor.visitRuleref(self)
            else:
                return visitor.visitChildren(self)




    def ruleref(self):

        localctx = ANTLRv4Parser.RulerefContext(self, self._ctx, self.state)
        self.enterRule(localctx, 110, self.RULE_ruleref)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 587
            localctx.value = self.match(ANTLRv4Parser.RULE_REF)
            self.state = 589
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==ANTLRv4Parser.BEGIN_ARGUMENT:
                self.state = 588
                self.argActionBlock()


            self.state = 592
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==ANTLRv4Parser.LT:
                self.state = 591
                self.elementOptions()


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class CharacterRangeContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser
            self.start = None # Token
            self.end = None # Token

        def RANGE(self):
            return self.getToken(ANTLRv4Parser.RANGE, 0)

        def STRING_LITERAL(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.STRING_LITERAL)
            else:
                return self.getToken(ANTLRv4Parser.STRING_LITERAL, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_characterRange

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterCharacterRange" ):
                listener.enterCharacterRange(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitCharacterRange" ):
                listener.exitCharacterRange(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitCharacterRange" ):
                return visitor.visitCharacterRange(self)
            else:
                return visitor.visitChildren(self)




    def characterRange(self):

        localctx = ANTLRv4Parser.CharacterRangeContext(self, self._ctx, self.state)
        self.enterRule(localctx, 112, self.RULE_characterRange)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 594
            localctx.start = self.match(ANTLRv4Parser.STRING_LITERAL)
            self.state = 595
            self.match(ANTLRv4Parser.RANGE)
            self.state = 596
            localctx.end = self.match(ANTLRv4Parser.STRING_LITERAL)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class TerminalContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_terminal

     
        def copyFrom(self, ctx:ParserRuleContext):
            super().copyFrom(ctx)



    class TerminalRefContext(TerminalContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.TerminalContext
            super().__init__(parser)
            self.value = None # Token
            self.copyFrom(ctx)

        def TOKEN_REF(self):
            return self.getToken(ANTLRv4Parser.TOKEN_REF, 0)
        def elementOptions(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ElementOptionsContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterTerminalRef" ):
                listener.enterTerminalRef(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitTerminalRef" ):
                listener.exitTerminalRef(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitTerminalRef" ):
                return visitor.visitTerminalRef(self)
            else:
                return visitor.visitChildren(self)


    class TerminalLitContext(TerminalContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.TerminalContext
            super().__init__(parser)
            self.value = None # Token
            self.copyFrom(ctx)

        def STRING_LITERAL(self):
            return self.getToken(ANTLRv4Parser.STRING_LITERAL, 0)
        def elementOptions(self):
            return self.getTypedRuleContext(ANTLRv4Parser.ElementOptionsContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterTerminalLit" ):
                listener.enterTerminalLit(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitTerminalLit" ):
                listener.exitTerminalLit(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitTerminalLit" ):
                return visitor.visitTerminalLit(self)
            else:
                return visitor.visitChildren(self)



    def terminal(self):

        localctx = ANTLRv4Parser.TerminalContext(self, self._ctx, self.state)
        self.enterRule(localctx, 114, self.RULE_terminal)
        self._la = 0 # Token type
        try:
            self.state = 606
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [ANTLRv4Parser.TOKEN_REF]:
                localctx = ANTLRv4Parser.TerminalRefContext(self, localctx)
                self.enterOuterAlt(localctx, 1)
                self.state = 598
                localctx.value = self.match(ANTLRv4Parser.TOKEN_REF)
                self.state = 600
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if _la==ANTLRv4Parser.LT:
                    self.state = 599
                    self.elementOptions()


                pass
            elif token in [ANTLRv4Parser.STRING_LITERAL]:
                localctx = ANTLRv4Parser.TerminalLitContext(self, localctx)
                self.enterOuterAlt(localctx, 2)
                self.state = 602
                localctx.value = self.match(ANTLRv4Parser.STRING_LITERAL)
                self.state = 604
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if _la==ANTLRv4Parser.LT:
                    self.state = 603
                    self.elementOptions()


                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class ElementOptionsContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def LT(self):
            return self.getToken(ANTLRv4Parser.LT, 0)

        def elementOption(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.ElementOptionContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.ElementOptionContext,i)


        def GT(self):
            return self.getToken(ANTLRv4Parser.GT, 0)

        def COMMA(self, i:int=None):
            if i is None:
                return self.getTokens(ANTLRv4Parser.COMMA)
            else:
                return self.getToken(ANTLRv4Parser.COMMA, i)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_elementOptions

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterElementOptions" ):
                listener.enterElementOptions(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitElementOptions" ):
                listener.exitElementOptions(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitElementOptions" ):
                return visitor.visitElementOptions(self)
            else:
                return visitor.visitChildren(self)




    def elementOptions(self):

        localctx = ANTLRv4Parser.ElementOptionsContext(self, self._ctx, self.state)
        self.enterRule(localctx, 116, self.RULE_elementOptions)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 608
            self.match(ANTLRv4Parser.LT)
            self.state = 609
            self.elementOption()
            self.state = 614
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==ANTLRv4Parser.COMMA:
                self.state = 610
                self.match(ANTLRv4Parser.COMMA)
                self.state = 611
                self.elementOption()
                self.state = 616
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 617
            self.match(ANTLRv4Parser.GT)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class ElementOptionContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def identifier(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(ANTLRv4Parser.IdentifierContext)
            else:
                return self.getTypedRuleContext(ANTLRv4Parser.IdentifierContext,i)


        def ASSIGN(self):
            return self.getToken(ANTLRv4Parser.ASSIGN, 0)

        def STRING_LITERAL(self):
            return self.getToken(ANTLRv4Parser.STRING_LITERAL, 0)

        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_elementOption

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterElementOption" ):
                listener.enterElementOption(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitElementOption" ):
                listener.exitElementOption(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitElementOption" ):
                return visitor.visitElementOption(self)
            else:
                return visitor.visitChildren(self)




    def elementOption(self):

        localctx = ANTLRv4Parser.ElementOptionContext(self, self._ctx, self.state)
        self.enterRule(localctx, 118, self.RULE_elementOption)
        try:
            self.state = 626
            self._errHandler.sync(self)
            la_ = self._interp.adaptivePredict(self._input,84,self._ctx)
            if la_ == 1:
                self.enterOuterAlt(localctx, 1)
                self.state = 619
                self.identifier()
                pass

            elif la_ == 2:
                self.enterOuterAlt(localctx, 2)
                self.state = 620
                self.identifier()
                self.state = 621
                self.match(ANTLRv4Parser.ASSIGN)
                self.state = 624
                self._errHandler.sync(self)
                token = self._input.LA(1)
                if token in [ANTLRv4Parser.TOKEN_REF, ANTLRv4Parser.RULE_REF]:
                    self.state = 622
                    self.identifier()
                    pass
                elif token in [ANTLRv4Parser.STRING_LITERAL]:
                    self.state = 623
                    self.match(ANTLRv4Parser.STRING_LITERAL)
                    pass
                else:
                    raise NoViableAltException(self)

                pass


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class IdentifierContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser


        def getRuleIndex(self):
            return ANTLRv4Parser.RULE_identifier

     
        def copyFrom(self, ctx:ParserRuleContext):
            super().copyFrom(ctx)



    class RuleRefIdentifierContext(IdentifierContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.IdentifierContext
            super().__init__(parser)
            self.value = None # Token
            self.copyFrom(ctx)

        def RULE_REF(self):
            return self.getToken(ANTLRv4Parser.RULE_REF, 0)

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterRuleRefIdentifier" ):
                listener.enterRuleRefIdentifier(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitRuleRefIdentifier" ):
                listener.exitRuleRefIdentifier(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitRuleRefIdentifier" ):
                return visitor.visitRuleRefIdentifier(self)
            else:
                return visitor.visitChildren(self)


    class TokenRefIdentifierContext(IdentifierContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a ANTLRv4Parser.IdentifierContext
            super().__init__(parser)
            self.value = None # Token
            self.copyFrom(ctx)

        def TOKEN_REF(self):
            return self.getToken(ANTLRv4Parser.TOKEN_REF, 0)

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterTokenRefIdentifier" ):
                listener.enterTokenRefIdentifier(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitTokenRefIdentifier" ):
                listener.exitTokenRefIdentifier(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitTokenRefIdentifier" ):
                return visitor.visitTokenRefIdentifier(self)
            else:
                return visitor.visitChildren(self)



    def identifier(self):

        localctx = ANTLRv4Parser.IdentifierContext(self, self._ctx, self.state)
        self.enterRule(localctx, 120, self.RULE_identifier)
        try:
            self.state = 630
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [ANTLRv4Parser.RULE_REF]:
                localctx = ANTLRv4Parser.RuleRefIdentifierContext(self, localctx)
                self.enterOuterAlt(localctx, 1)
                self.state = 628
                localctx.value = self.match(ANTLRv4Parser.RULE_REF)
                pass
            elif token in [ANTLRv4Parser.TOKEN_REF]:
                localctx = ANTLRv4Parser.TokenRefIdentifierContext(self, localctx)
                self.enterOuterAlt(localctx, 2)
                self.state = 629
                localctx.value = self.match(ANTLRv4Parser.TOKEN_REF)
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx
