from antlr4 import *
if __name__ is not None and "." in __name__:
    from .ANTLRv4Parser import ANTLRv4Parser
else:
    from ANTLRv4Parser import ANTLRv4Parser

# This class defines a complete listener for a parse tree produced by ANTLRv4Parser.
class ANTLRv4ParserListener(ParseTreeListener):

    # Enter a parse tree produced by ANTLRv4Parser#grammarSpec.
    def enterGrammarSpec(self, ctx:ANTLRv4Parser.GrammarSpecContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#grammarSpec.
    def exitGrammarSpec(self, ctx:ANTLRv4Parser.GrammarSpecContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#grammarType.
    def enterGrammarType(self, ctx:ANTLRv4Parser.GrammarTypeContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#grammarType.
    def exitGrammarType(self, ctx:ANTLRv4Parser.GrammarTypeContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#prequelConstruct.
    def enterPrequelConstruct(self, ctx:ANTLRv4Parser.PrequelConstructContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#prequelConstruct.
    def exitPrequelConstruct(self, ctx:ANTLRv4Parser.PrequelConstructContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#optionsSpec.
    def enterOptionsSpec(self, ctx:ANTLRv4Parser.OptionsSpecContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#optionsSpec.
    def exitOptionsSpec(self, ctx:ANTLRv4Parser.OptionsSpecContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#option.
    def enterOption(self, ctx:ANTLRv4Parser.OptionContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#option.
    def exitOption(self, ctx:ANTLRv4Parser.OptionContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#pathOption.
    def enterPathOption(self, ctx:ANTLRv4Parser.PathOptionContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#pathOption.
    def exitPathOption(self, ctx:ANTLRv4Parser.PathOptionContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#stringOption.
    def enterStringOption(self, ctx:ANTLRv4Parser.StringOptionContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#stringOption.
    def exitStringOption(self, ctx:ANTLRv4Parser.StringOptionContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#actionOption.
    def enterActionOption(self, ctx:ANTLRv4Parser.ActionOptionContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#actionOption.
    def exitActionOption(self, ctx:ANTLRv4Parser.ActionOptionContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#intOption.
    def enterIntOption(self, ctx:ANTLRv4Parser.IntOptionContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#intOption.
    def exitIntOption(self, ctx:ANTLRv4Parser.IntOptionContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#delegateGrammars.
    def enterDelegateGrammars(self, ctx:ANTLRv4Parser.DelegateGrammarsContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#delegateGrammars.
    def exitDelegateGrammars(self, ctx:ANTLRv4Parser.DelegateGrammarsContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#delegateGrammar.
    def enterDelegateGrammar(self, ctx:ANTLRv4Parser.DelegateGrammarContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#delegateGrammar.
    def exitDelegateGrammar(self, ctx:ANTLRv4Parser.DelegateGrammarContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#tokensSpec.
    def enterTokensSpec(self, ctx:ANTLRv4Parser.TokensSpecContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#tokensSpec.
    def exitTokensSpec(self, ctx:ANTLRv4Parser.TokensSpecContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#channelsSpec.
    def enterChannelsSpec(self, ctx:ANTLRv4Parser.ChannelsSpecContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#channelsSpec.
    def exitChannelsSpec(self, ctx:ANTLRv4Parser.ChannelsSpecContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#idList.
    def enterIdList(self, ctx:ANTLRv4Parser.IdListContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#idList.
    def exitIdList(self, ctx:ANTLRv4Parser.IdListContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#action.
    def enterAction(self, ctx:ANTLRv4Parser.ActionContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#action.
    def exitAction(self, ctx:ANTLRv4Parser.ActionContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#actionScopeName.
    def enterActionScopeName(self, ctx:ANTLRv4Parser.ActionScopeNameContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#actionScopeName.
    def exitActionScopeName(self, ctx:ANTLRv4Parser.ActionScopeNameContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#actionBlock.
    def enterActionBlock(self, ctx:ANTLRv4Parser.ActionBlockContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#actionBlock.
    def exitActionBlock(self, ctx:ANTLRv4Parser.ActionBlockContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#argActionBlock.
    def enterArgActionBlock(self, ctx:ANTLRv4Parser.ArgActionBlockContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#argActionBlock.
    def exitArgActionBlock(self, ctx:ANTLRv4Parser.ArgActionBlockContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#modeSpec.
    def enterModeSpec(self, ctx:ANTLRv4Parser.ModeSpecContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#modeSpec.
    def exitModeSpec(self, ctx:ANTLRv4Parser.ModeSpecContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#rules.
    def enterRules(self, ctx:ANTLRv4Parser.RulesContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#rules.
    def exitRules(self, ctx:ANTLRv4Parser.RulesContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#ruleSpec.
    def enterRuleSpec(self, ctx:ANTLRv4Parser.RuleSpecContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#ruleSpec.
    def exitRuleSpec(self, ctx:ANTLRv4Parser.RuleSpecContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#parserRuleSpec.
    def enterParserRuleSpec(self, ctx:ANTLRv4Parser.ParserRuleSpecContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#parserRuleSpec.
    def exitParserRuleSpec(self, ctx:ANTLRv4Parser.ParserRuleSpecContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#exceptionGroup.
    def enterExceptionGroup(self, ctx:ANTLRv4Parser.ExceptionGroupContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#exceptionGroup.
    def exitExceptionGroup(self, ctx:ANTLRv4Parser.ExceptionGroupContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#exceptionHandler.
    def enterExceptionHandler(self, ctx:ANTLRv4Parser.ExceptionHandlerContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#exceptionHandler.
    def exitExceptionHandler(self, ctx:ANTLRv4Parser.ExceptionHandlerContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#finallyClause.
    def enterFinallyClause(self, ctx:ANTLRv4Parser.FinallyClauseContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#finallyClause.
    def exitFinallyClause(self, ctx:ANTLRv4Parser.FinallyClauseContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#rulePrequel.
    def enterRulePrequel(self, ctx:ANTLRv4Parser.RulePrequelContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#rulePrequel.
    def exitRulePrequel(self, ctx:ANTLRv4Parser.RulePrequelContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#ruleReturns.
    def enterRuleReturns(self, ctx:ANTLRv4Parser.RuleReturnsContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#ruleReturns.
    def exitRuleReturns(self, ctx:ANTLRv4Parser.RuleReturnsContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#throwsSpec.
    def enterThrowsSpec(self, ctx:ANTLRv4Parser.ThrowsSpecContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#throwsSpec.
    def exitThrowsSpec(self, ctx:ANTLRv4Parser.ThrowsSpecContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#localsSpec.
    def enterLocalsSpec(self, ctx:ANTLRv4Parser.LocalsSpecContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#localsSpec.
    def exitLocalsSpec(self, ctx:ANTLRv4Parser.LocalsSpecContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#ruleAction.
    def enterRuleAction(self, ctx:ANTLRv4Parser.RuleActionContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#ruleAction.
    def exitRuleAction(self, ctx:ANTLRv4Parser.RuleActionContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#ruleModifiers.
    def enterRuleModifiers(self, ctx:ANTLRv4Parser.RuleModifiersContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#ruleModifiers.
    def exitRuleModifiers(self, ctx:ANTLRv4Parser.RuleModifiersContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#ruleModifier.
    def enterRuleModifier(self, ctx:ANTLRv4Parser.RuleModifierContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#ruleModifier.
    def exitRuleModifier(self, ctx:ANTLRv4Parser.RuleModifierContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#ruleBlock.
    def enterRuleBlock(self, ctx:ANTLRv4Parser.RuleBlockContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#ruleBlock.
    def exitRuleBlock(self, ctx:ANTLRv4Parser.RuleBlockContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#ruleAltList.
    def enterRuleAltList(self, ctx:ANTLRv4Parser.RuleAltListContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#ruleAltList.
    def exitRuleAltList(self, ctx:ANTLRv4Parser.RuleAltListContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#labeledAlt.
    def enterLabeledAlt(self, ctx:ANTLRv4Parser.LabeledAltContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#labeledAlt.
    def exitLabeledAlt(self, ctx:ANTLRv4Parser.LabeledAltContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerRuleSpec.
    def enterLexerRuleSpec(self, ctx:ANTLRv4Parser.LexerRuleSpecContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerRuleSpec.
    def exitLexerRuleSpec(self, ctx:ANTLRv4Parser.LexerRuleSpecContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerRuleBlock.
    def enterLexerRuleBlock(self, ctx:ANTLRv4Parser.LexerRuleBlockContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerRuleBlock.
    def exitLexerRuleBlock(self, ctx:ANTLRv4Parser.LexerRuleBlockContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerAltList.
    def enterLexerAltList(self, ctx:ANTLRv4Parser.LexerAltListContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerAltList.
    def exitLexerAltList(self, ctx:ANTLRv4Parser.LexerAltListContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerAlt.
    def enterLexerAlt(self, ctx:ANTLRv4Parser.LexerAltContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerAlt.
    def exitLexerAlt(self, ctx:ANTLRv4Parser.LexerAltContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerElements.
    def enterLexerElements(self, ctx:ANTLRv4Parser.LexerElementsContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerElements.
    def exitLexerElements(self, ctx:ANTLRv4Parser.LexerElementsContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerElementLabeled.
    def enterLexerElementLabeled(self, ctx:ANTLRv4Parser.LexerElementLabeledContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerElementLabeled.
    def exitLexerElementLabeled(self, ctx:ANTLRv4Parser.LexerElementLabeledContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerElementAtom.
    def enterLexerElementAtom(self, ctx:ANTLRv4Parser.LexerElementAtomContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerElementAtom.
    def exitLexerElementAtom(self, ctx:ANTLRv4Parser.LexerElementAtomContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerElementBlock.
    def enterLexerElementBlock(self, ctx:ANTLRv4Parser.LexerElementBlockContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerElementBlock.
    def exitLexerElementBlock(self, ctx:ANTLRv4Parser.LexerElementBlockContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerElementAction.
    def enterLexerElementAction(self, ctx:ANTLRv4Parser.LexerElementActionContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerElementAction.
    def exitLexerElementAction(self, ctx:ANTLRv4Parser.LexerElementActionContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#labeledLexerElement.
    def enterLabeledLexerElement(self, ctx:ANTLRv4Parser.LabeledLexerElementContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#labeledLexerElement.
    def exitLabeledLexerElement(self, ctx:ANTLRv4Parser.LabeledLexerElementContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerBlock.
    def enterLexerBlock(self, ctx:ANTLRv4Parser.LexerBlockContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerBlock.
    def exitLexerBlock(self, ctx:ANTLRv4Parser.LexerBlockContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerCommands.
    def enterLexerCommands(self, ctx:ANTLRv4Parser.LexerCommandsContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerCommands.
    def exitLexerCommands(self, ctx:ANTLRv4Parser.LexerCommandsContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerCommand.
    def enterLexerCommand(self, ctx:ANTLRv4Parser.LexerCommandContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerCommand.
    def exitLexerCommand(self, ctx:ANTLRv4Parser.LexerCommandContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerCommandName.
    def enterLexerCommandName(self, ctx:ANTLRv4Parser.LexerCommandNameContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerCommandName.
    def exitLexerCommandName(self, ctx:ANTLRv4Parser.LexerCommandNameContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerCommandExpr.
    def enterLexerCommandExpr(self, ctx:ANTLRv4Parser.LexerCommandExprContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerCommandExpr.
    def exitLexerCommandExpr(self, ctx:ANTLRv4Parser.LexerCommandExprContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#altList.
    def enterAltList(self, ctx:ANTLRv4Parser.AltListContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#altList.
    def exitAltList(self, ctx:ANTLRv4Parser.AltListContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#alternative.
    def enterAlternative(self, ctx:ANTLRv4Parser.AlternativeContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#alternative.
    def exitAlternative(self, ctx:ANTLRv4Parser.AlternativeContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#parserElementLabeled.
    def enterParserElementLabeled(self, ctx:ANTLRv4Parser.ParserElementLabeledContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#parserElementLabeled.
    def exitParserElementLabeled(self, ctx:ANTLRv4Parser.ParserElementLabeledContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#parserElementAtom.
    def enterParserElementAtom(self, ctx:ANTLRv4Parser.ParserElementAtomContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#parserElementAtom.
    def exitParserElementAtom(self, ctx:ANTLRv4Parser.ParserElementAtomContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#parserElementBlock.
    def enterParserElementBlock(self, ctx:ANTLRv4Parser.ParserElementBlockContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#parserElementBlock.
    def exitParserElementBlock(self, ctx:ANTLRv4Parser.ParserElementBlockContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#parserElementAction.
    def enterParserElementAction(self, ctx:ANTLRv4Parser.ParserElementActionContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#parserElementAction.
    def exitParserElementAction(self, ctx:ANTLRv4Parser.ParserElementActionContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#parserInlineDoc.
    def enterParserInlineDoc(self, ctx:ANTLRv4Parser.ParserInlineDocContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#parserInlineDoc.
    def exitParserInlineDoc(self, ctx:ANTLRv4Parser.ParserInlineDocContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#labeledElement.
    def enterLabeledElement(self, ctx:ANTLRv4Parser.LabeledElementContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#labeledElement.
    def exitLabeledElement(self, ctx:ANTLRv4Parser.LabeledElementContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#ebnfSuffix.
    def enterEbnfSuffix(self, ctx:ANTLRv4Parser.EbnfSuffixContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#ebnfSuffix.
    def exitEbnfSuffix(self, ctx:ANTLRv4Parser.EbnfSuffixContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerAtomRange.
    def enterLexerAtomRange(self, ctx:ANTLRv4Parser.LexerAtomRangeContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerAtomRange.
    def exitLexerAtomRange(self, ctx:ANTLRv4Parser.LexerAtomRangeContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerAtomTerminal.
    def enterLexerAtomTerminal(self, ctx:ANTLRv4Parser.LexerAtomTerminalContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerAtomTerminal.
    def exitLexerAtomTerminal(self, ctx:ANTLRv4Parser.LexerAtomTerminalContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerAtomNot.
    def enterLexerAtomNot(self, ctx:ANTLRv4Parser.LexerAtomNotContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerAtomNot.
    def exitLexerAtomNot(self, ctx:ANTLRv4Parser.LexerAtomNotContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerAtomCharSet.
    def enterLexerAtomCharSet(self, ctx:ANTLRv4Parser.LexerAtomCharSetContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerAtomCharSet.
    def exitLexerAtomCharSet(self, ctx:ANTLRv4Parser.LexerAtomCharSetContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerAtomWildcard.
    def enterLexerAtomWildcard(self, ctx:ANTLRv4Parser.LexerAtomWildcardContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerAtomWildcard.
    def exitLexerAtomWildcard(self, ctx:ANTLRv4Parser.LexerAtomWildcardContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#lexerAtomDoc.
    def enterLexerAtomDoc(self, ctx:ANTLRv4Parser.LexerAtomDocContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#lexerAtomDoc.
    def exitLexerAtomDoc(self, ctx:ANTLRv4Parser.LexerAtomDocContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#atomTerminal.
    def enterAtomTerminal(self, ctx:ANTLRv4Parser.AtomTerminalContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#atomTerminal.
    def exitAtomTerminal(self, ctx:ANTLRv4Parser.AtomTerminalContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#atomRuleRef.
    def enterAtomRuleRef(self, ctx:ANTLRv4Parser.AtomRuleRefContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#atomRuleRef.
    def exitAtomRuleRef(self, ctx:ANTLRv4Parser.AtomRuleRefContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#atomNot.
    def enterAtomNot(self, ctx:ANTLRv4Parser.AtomNotContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#atomNot.
    def exitAtomNot(self, ctx:ANTLRv4Parser.AtomNotContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#atomWildcard.
    def enterAtomWildcard(self, ctx:ANTLRv4Parser.AtomWildcardContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#atomWildcard.
    def exitAtomWildcard(self, ctx:ANTLRv4Parser.AtomWildcardContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#notElement.
    def enterNotElement(self, ctx:ANTLRv4Parser.NotElementContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#notElement.
    def exitNotElement(self, ctx:ANTLRv4Parser.NotElementContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#notBlock.
    def enterNotBlock(self, ctx:ANTLRv4Parser.NotBlockContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#notBlock.
    def exitNotBlock(self, ctx:ANTLRv4Parser.NotBlockContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#blockSet.
    def enterBlockSet(self, ctx:ANTLRv4Parser.BlockSetContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#blockSet.
    def exitBlockSet(self, ctx:ANTLRv4Parser.BlockSetContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#setElementRef.
    def enterSetElementRef(self, ctx:ANTLRv4Parser.SetElementRefContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#setElementRef.
    def exitSetElementRef(self, ctx:ANTLRv4Parser.SetElementRefContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#setElementLit.
    def enterSetElementLit(self, ctx:ANTLRv4Parser.SetElementLitContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#setElementLit.
    def exitSetElementLit(self, ctx:ANTLRv4Parser.SetElementLitContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#setElementRange.
    def enterSetElementRange(self, ctx:ANTLRv4Parser.SetElementRangeContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#setElementRange.
    def exitSetElementRange(self, ctx:ANTLRv4Parser.SetElementRangeContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#setElementCharSet.
    def enterSetElementCharSet(self, ctx:ANTLRv4Parser.SetElementCharSetContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#setElementCharSet.
    def exitSetElementCharSet(self, ctx:ANTLRv4Parser.SetElementCharSetContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#block.
    def enterBlock(self, ctx:ANTLRv4Parser.BlockContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#block.
    def exitBlock(self, ctx:ANTLRv4Parser.BlockContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#ruleref.
    def enterRuleref(self, ctx:ANTLRv4Parser.RulerefContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#ruleref.
    def exitRuleref(self, ctx:ANTLRv4Parser.RulerefContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#characterRange.
    def enterCharacterRange(self, ctx:ANTLRv4Parser.CharacterRangeContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#characterRange.
    def exitCharacterRange(self, ctx:ANTLRv4Parser.CharacterRangeContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#terminalRef.
    def enterTerminalRef(self, ctx:ANTLRv4Parser.TerminalRefContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#terminalRef.
    def exitTerminalRef(self, ctx:ANTLRv4Parser.TerminalRefContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#terminalLit.
    def enterTerminalLit(self, ctx:ANTLRv4Parser.TerminalLitContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#terminalLit.
    def exitTerminalLit(self, ctx:ANTLRv4Parser.TerminalLitContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#elementOptions.
    def enterElementOptions(self, ctx:ANTLRv4Parser.ElementOptionsContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#elementOptions.
    def exitElementOptions(self, ctx:ANTLRv4Parser.ElementOptionsContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#elementOption.
    def enterElementOption(self, ctx:ANTLRv4Parser.ElementOptionContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#elementOption.
    def exitElementOption(self, ctx:ANTLRv4Parser.ElementOptionContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#ruleRefIdentifier.
    def enterRuleRefIdentifier(self, ctx:ANTLRv4Parser.RuleRefIdentifierContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#ruleRefIdentifier.
    def exitRuleRefIdentifier(self, ctx:ANTLRv4Parser.RuleRefIdentifierContext):
        pass


    # Enter a parse tree produced by ANTLRv4Parser#tokenRefIdentifier.
    def enterTokenRefIdentifier(self, ctx:ANTLRv4Parser.TokenRefIdentifierContext):
        pass

    # Exit a parse tree produced by ANTLRv4Parser#tokenRefIdentifier.
    def exitTokenRefIdentifier(self, ctx:ANTLRv4Parser.TokenRefIdentifierContext):
        pass
