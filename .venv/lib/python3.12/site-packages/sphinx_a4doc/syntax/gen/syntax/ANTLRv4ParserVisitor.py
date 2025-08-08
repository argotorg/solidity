from antlr4 import *
if __name__ is not None and "." in __name__:
    from .ANTLRv4Parser import ANTLRv4Parser
else:
    from ANTLRv4Parser import ANTLRv4Parser

# This class defines a complete generic visitor for a parse tree produced by ANTLRv4Parser.

class ANTLRv4ParserVisitor(ParseTreeVisitor):

    # Visit a parse tree produced by ANTLRv4Parser#grammarSpec.
    def visitGrammarSpec(self, ctx:ANTLRv4Parser.GrammarSpecContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#grammarType.
    def visitGrammarType(self, ctx:ANTLRv4Parser.GrammarTypeContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#prequelConstruct.
    def visitPrequelConstruct(self, ctx:ANTLRv4Parser.PrequelConstructContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#optionsSpec.
    def visitOptionsSpec(self, ctx:ANTLRv4Parser.OptionsSpecContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#option.
    def visitOption(self, ctx:ANTLRv4Parser.OptionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#pathOption.
    def visitPathOption(self, ctx:ANTLRv4Parser.PathOptionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#stringOption.
    def visitStringOption(self, ctx:ANTLRv4Parser.StringOptionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#actionOption.
    def visitActionOption(self, ctx:ANTLRv4Parser.ActionOptionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#intOption.
    def visitIntOption(self, ctx:ANTLRv4Parser.IntOptionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#delegateGrammars.
    def visitDelegateGrammars(self, ctx:ANTLRv4Parser.DelegateGrammarsContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#delegateGrammar.
    def visitDelegateGrammar(self, ctx:ANTLRv4Parser.DelegateGrammarContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#tokensSpec.
    def visitTokensSpec(self, ctx:ANTLRv4Parser.TokensSpecContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#channelsSpec.
    def visitChannelsSpec(self, ctx:ANTLRv4Parser.ChannelsSpecContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#idList.
    def visitIdList(self, ctx:ANTLRv4Parser.IdListContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#action.
    def visitAction(self, ctx:ANTLRv4Parser.ActionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#actionScopeName.
    def visitActionScopeName(self, ctx:ANTLRv4Parser.ActionScopeNameContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#actionBlock.
    def visitActionBlock(self, ctx:ANTLRv4Parser.ActionBlockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#argActionBlock.
    def visitArgActionBlock(self, ctx:ANTLRv4Parser.ArgActionBlockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#modeSpec.
    def visitModeSpec(self, ctx:ANTLRv4Parser.ModeSpecContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#rules.
    def visitRules(self, ctx:ANTLRv4Parser.RulesContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#ruleSpec.
    def visitRuleSpec(self, ctx:ANTLRv4Parser.RuleSpecContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#parserRuleSpec.
    def visitParserRuleSpec(self, ctx:ANTLRv4Parser.ParserRuleSpecContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#exceptionGroup.
    def visitExceptionGroup(self, ctx:ANTLRv4Parser.ExceptionGroupContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#exceptionHandler.
    def visitExceptionHandler(self, ctx:ANTLRv4Parser.ExceptionHandlerContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#finallyClause.
    def visitFinallyClause(self, ctx:ANTLRv4Parser.FinallyClauseContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#rulePrequel.
    def visitRulePrequel(self, ctx:ANTLRv4Parser.RulePrequelContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#ruleReturns.
    def visitRuleReturns(self, ctx:ANTLRv4Parser.RuleReturnsContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#throwsSpec.
    def visitThrowsSpec(self, ctx:ANTLRv4Parser.ThrowsSpecContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#localsSpec.
    def visitLocalsSpec(self, ctx:ANTLRv4Parser.LocalsSpecContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#ruleAction.
    def visitRuleAction(self, ctx:ANTLRv4Parser.RuleActionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#ruleModifiers.
    def visitRuleModifiers(self, ctx:ANTLRv4Parser.RuleModifiersContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#ruleModifier.
    def visitRuleModifier(self, ctx:ANTLRv4Parser.RuleModifierContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#ruleBlock.
    def visitRuleBlock(self, ctx:ANTLRv4Parser.RuleBlockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#ruleAltList.
    def visitRuleAltList(self, ctx:ANTLRv4Parser.RuleAltListContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#labeledAlt.
    def visitLabeledAlt(self, ctx:ANTLRv4Parser.LabeledAltContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerRuleSpec.
    def visitLexerRuleSpec(self, ctx:ANTLRv4Parser.LexerRuleSpecContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerRuleBlock.
    def visitLexerRuleBlock(self, ctx:ANTLRv4Parser.LexerRuleBlockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerAltList.
    def visitLexerAltList(self, ctx:ANTLRv4Parser.LexerAltListContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerAlt.
    def visitLexerAlt(self, ctx:ANTLRv4Parser.LexerAltContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerElements.
    def visitLexerElements(self, ctx:ANTLRv4Parser.LexerElementsContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerElementLabeled.
    def visitLexerElementLabeled(self, ctx:ANTLRv4Parser.LexerElementLabeledContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerElementAtom.
    def visitLexerElementAtom(self, ctx:ANTLRv4Parser.LexerElementAtomContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerElementBlock.
    def visitLexerElementBlock(self, ctx:ANTLRv4Parser.LexerElementBlockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerElementAction.
    def visitLexerElementAction(self, ctx:ANTLRv4Parser.LexerElementActionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#labeledLexerElement.
    def visitLabeledLexerElement(self, ctx:ANTLRv4Parser.LabeledLexerElementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerBlock.
    def visitLexerBlock(self, ctx:ANTLRv4Parser.LexerBlockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerCommands.
    def visitLexerCommands(self, ctx:ANTLRv4Parser.LexerCommandsContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerCommand.
    def visitLexerCommand(self, ctx:ANTLRv4Parser.LexerCommandContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerCommandName.
    def visitLexerCommandName(self, ctx:ANTLRv4Parser.LexerCommandNameContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerCommandExpr.
    def visitLexerCommandExpr(self, ctx:ANTLRv4Parser.LexerCommandExprContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#altList.
    def visitAltList(self, ctx:ANTLRv4Parser.AltListContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#alternative.
    def visitAlternative(self, ctx:ANTLRv4Parser.AlternativeContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#parserElementLabeled.
    def visitParserElementLabeled(self, ctx:ANTLRv4Parser.ParserElementLabeledContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#parserElementAtom.
    def visitParserElementAtom(self, ctx:ANTLRv4Parser.ParserElementAtomContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#parserElementBlock.
    def visitParserElementBlock(self, ctx:ANTLRv4Parser.ParserElementBlockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#parserElementAction.
    def visitParserElementAction(self, ctx:ANTLRv4Parser.ParserElementActionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#parserInlineDoc.
    def visitParserInlineDoc(self, ctx:ANTLRv4Parser.ParserInlineDocContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#labeledElement.
    def visitLabeledElement(self, ctx:ANTLRv4Parser.LabeledElementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#ebnfSuffix.
    def visitEbnfSuffix(self, ctx:ANTLRv4Parser.EbnfSuffixContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerAtomRange.
    def visitLexerAtomRange(self, ctx:ANTLRv4Parser.LexerAtomRangeContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerAtomTerminal.
    def visitLexerAtomTerminal(self, ctx:ANTLRv4Parser.LexerAtomTerminalContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerAtomNot.
    def visitLexerAtomNot(self, ctx:ANTLRv4Parser.LexerAtomNotContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerAtomCharSet.
    def visitLexerAtomCharSet(self, ctx:ANTLRv4Parser.LexerAtomCharSetContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerAtomWildcard.
    def visitLexerAtomWildcard(self, ctx:ANTLRv4Parser.LexerAtomWildcardContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#lexerAtomDoc.
    def visitLexerAtomDoc(self, ctx:ANTLRv4Parser.LexerAtomDocContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#atomTerminal.
    def visitAtomTerminal(self, ctx:ANTLRv4Parser.AtomTerminalContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#atomRuleRef.
    def visitAtomRuleRef(self, ctx:ANTLRv4Parser.AtomRuleRefContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#atomNot.
    def visitAtomNot(self, ctx:ANTLRv4Parser.AtomNotContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#atomWildcard.
    def visitAtomWildcard(self, ctx:ANTLRv4Parser.AtomWildcardContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#notElement.
    def visitNotElement(self, ctx:ANTLRv4Parser.NotElementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#notBlock.
    def visitNotBlock(self, ctx:ANTLRv4Parser.NotBlockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#blockSet.
    def visitBlockSet(self, ctx:ANTLRv4Parser.BlockSetContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#setElementRef.
    def visitSetElementRef(self, ctx:ANTLRv4Parser.SetElementRefContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#setElementLit.
    def visitSetElementLit(self, ctx:ANTLRv4Parser.SetElementLitContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#setElementRange.
    def visitSetElementRange(self, ctx:ANTLRv4Parser.SetElementRangeContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#setElementCharSet.
    def visitSetElementCharSet(self, ctx:ANTLRv4Parser.SetElementCharSetContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#block.
    def visitBlock(self, ctx:ANTLRv4Parser.BlockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#ruleref.
    def visitRuleref(self, ctx:ANTLRv4Parser.RulerefContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#characterRange.
    def visitCharacterRange(self, ctx:ANTLRv4Parser.CharacterRangeContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#terminalRef.
    def visitTerminalRef(self, ctx:ANTLRv4Parser.TerminalRefContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#terminalLit.
    def visitTerminalLit(self, ctx:ANTLRv4Parser.TerminalLitContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#elementOptions.
    def visitElementOptions(self, ctx:ANTLRv4Parser.ElementOptionsContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#elementOption.
    def visitElementOption(self, ctx:ANTLRv4Parser.ElementOptionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#ruleRefIdentifier.
    def visitRuleRefIdentifier(self, ctx:ANTLRv4Parser.RuleRefIdentifierContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by ANTLRv4Parser#tokenRefIdentifier.
    def visitTokenRefIdentifier(self, ctx:ANTLRv4Parser.TokenRefIdentifierContext):
        return self.visitChildren(ctx)



del ANTLRv4Parser
