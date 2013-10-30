package org.liujing.antlr.parser;

import org.liujing.ironsword.grammar.*;
import java.util.*;
import org.liujing.antlr.parser.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;
import java.io.*;

public class LessCssParserListener extends MyCSSBaseListener{
	private Antlr4GrammarHandler agh = new Antlr4GrammarHandler();
	
	private BufferedTokenStream tokenStream;
	
	public LessCssParserListener(BufferedTokenStream tokens){
		tokenStream = tokens;
	}
	
	protected void addDocNode(Token t){
		int i = t.getTokenIndex();
		List<Token> tlist = tokenStream.getHiddenTokensToLeft(i, MyCSSParser.DOC_CHANN);
		if( tlist != null && tlist.size() > 0){
			CommonToken doct = (CommonToken) tlist.get(0);
			agh.addNode("doc", doct.getText(), doct, doct);
		}
	}
	
	@Override 
	public void enterCssfile( MyCSSParser.CssfileContext ctx) {
		agh.enterRule("css",ctx);
	}

	@Override 
	public void exitCssfile( MyCSSParser.CssfileContext ctx) {
		agh.exitRule(ctx);
	}
	
	@Override 
	public void enterCssRule( MyCSSParser.CssRuleContext ctx) {
		addDocNode(ctx.getStart());
		agh.enterRule("rule",ctx);
		agh.setName(ctx.RULE_NAME().getText());
	}

	@Override 
	public void exitCssRule( MyCSSParser.CssRuleContext ctx) { 
		agh.exitRule(ctx);
	}
	

	@Override public void enterCssUnit( MyCSSParser.CssUnitContext ctx) {
		addDocNode(ctx.getStart());
		agh.enterRule("unit", ctx);
	}
	
	@Override public void exitCssUnit( MyCSSParser.CssUnitContext ctx) {
		agh.setName(ctx.selector().getText());
		agh.exitRule(ctx);
	}

	
	public static void main(String[] args) throws Exception{
		System.out.println("+++++++");
		MyCSSLexer lexer = new MyCSSLexer(new ANTLRFileStream(args[0], "utf-8"));
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		MyCSSParser parser = new MyCSSParser(tokens);
		//ParseTreeWalker walker = new ParseTreeWalker();
		LessCssParserListener pListener = new LessCssParserListener(tokens);
		ParseTree tree = parser.cssfile();
		System.out.println(" -----start------ debug parse tree ------------");
		System.out.println(TreePrinterUtil.stringifyTree(tree, parser));
		//System.out.println(Trees.toStringTree(tree, parser));
		System.out.println(" ------end----- debug parse tree ------------");
		ParseTreeWalker.DEFAULT.walk(pListener, tree);
		pListener.agh.getNode().setName(args[0]);
		System.out.println(pListener.agh.getNode().toString());
	}
}
