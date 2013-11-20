package org.liujing.antlr.parser;

import org.liujing.ironsword.grammar.*;
import java.util.*;
import org.liujing.antlr.parser.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;
import java.io.*;
import static org.liujing.antlr.parser.Antlr4Parser.*;

public class Antlr4ParserHandler extends Antlr4ParserBaseListener{
	
	private Antlr4GrammarHandler agh = new Antlr4GrammarHandler();
	
	public Antlr4ParserHandler(CommonTokenStream cts){
		
	}
	
	@Override 
	public void enterParseGrammar( Antlr4Parser.ParseGrammarContext ctx) {
		agh.enterRule("grammar", ctx);
	}
	
	@Override 
	public void exitParseGrammar( Antlr4Parser.ParseGrammarContext ctx) {
		agh.exitRule(ctx);
	}
	
	@Override
	public void enterParseOptions(Antlr4Parser.ParseOptionsContext ctx){
		agh.enterRule("option", ctx);
		agh.setName("option");
	}
	
	@Override
	public void exitParseOptions(Antlr4Parser.ParseOptionsContext ctx){
		agh.exitRule(ctx);
	}
	
	@Override public void enterGlobalAction( Antlr4Parser.GlobalActionContext ctx) { 
		agh.enterRule("action", ctx);
		ActionScopeNameContext nameCtx = ctx.actionScopeName();
		if(nameCtx != null){
			agh.setName("@"+ nameCtx.getText()+"::" + ctx.ID().getText());
		}else{
			agh.setName("@"+ ctx.ID().getText());
		}
	}

	@Override public void exitGlobalAction( Antlr4Parser.GlobalActionContext ctx) {
		agh.exitRule(ctx);
	}

	@Override
	public void enterGrammarRule(GrammarRuleContext ctx){
		String ruleName = ctx.ID().getText();
		if(Character.isUpperCase(ruleName.charAt(0)))
			agh.enterRule("lexer-rule", ctx);
		else
			agh.enterRule("parser-rule", ctx);
		agh.setName(ruleName);
	}
	
	public void exitGrammarRule(GrammarRuleContext ctx){
		agh.exitRule(ctx);
	}
	
	public static void main(String[] args) throws Exception{
		Antlr4Lexer lexer = new Antlr4Lexer(new ANTLRFileStream(args[0], "utf-8"));
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		Antlr4Parser parser = new Antlr4Parser(tokens);
		Antlr4ParserHandler pListener = new Antlr4ParserHandler(tokens);
		TreePrinterUtil.verboseErrorInfo(parser);
		
		ParseTree tree = parser.parseGrammar();
		System.out.println(" -----start------ debug parse tree ------------");
		System.out.println(TreePrinterUtil.stringifyTree(tree, parser));
		System.out.println(" ------end----- debug parse tree ------------");
		ParseTreeWalker.DEFAULT.walk(pListener, tree);
		pListener.agh.getNode().setName(args[0]);
		System.out.println(pListener.agh.getNode().toString());
	}

}

