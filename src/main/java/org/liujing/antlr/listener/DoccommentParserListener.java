package org.liujing.antlr.parser;

import org.liujing.ironsword.grammar.*;
import java.util.*;
import java.util.logging.*;
import org.liujing.antlr.parser.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

import java.io.*;


public class DoccommentParserListener extends DoccommentBaseListener{
	
	private BufferedTokenStream tokenStream;
	private CharStream sourceStream;
	private StringBuilder descBuf;
	private Token descToken;
	
	private Antlr4GrammarHandler agh = new Antlr4GrammarHandler();
	
	public DoccommentParserListener(BufferedTokenStream tokens){
		tokenStream = tokens;
	}
	
	public DoccommentParserListener(BufferedTokenStream tokens, CharStream source){
		this(tokens);
		sourceStream = source;
	}
	
	public void enterDoc( DoccommentParser.DocContext ctx) { 
		agh.enterRule("doc", ctx);
	}
	
	public void exitDoc( DoccommentParser.DocContext ctx) {
		if(descBuf != null)
			agh.addNode("desc", descBuf.toString(), descToken, descToken);
		agh.exitRule(ctx);
	}
	
	public void enterAnotations(DoccommentParser.AnotationsContext ctx) {
		Token t = ctx.AnoName().getSymbol();
		List<TerminalNode> others = ctx.OTHER();
		agh.addNode("antotation", ctx.AnoName().getText().substring(1) + " - "+ 
			text(others.get(0).getSymbol(), others.get(others.size() -1).getSymbol()), t, t);
	}
	
	public void enterDesc(DoccommentParser.DescContext ctx){
		String desc = text(ctx.getStart(), ctx.getStop());
		if(descBuf == null)
			descBuf = new StringBuilder(desc);
		else
			descBuf.append(desc);
		if(descToken == null)
			descToken = ctx.getStart();
		
	}
	
	private String text(Token start, Token stop){
		return TreePrinterUtil.allText(sourceStream, start, stop);
	}
	
	public static Antlr4GrammarNode parse2Grammar(String s) throws IOException{
		CharStream src = new ANTLRInputStream(s);
		DoccommentLexer lexer = new DoccommentLexer(src);
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		DoccommentParser parser = new DoccommentParser(tokens);
		DoccommentParserListener pListener = new DoccommentParserListener(tokens, src);
		TreePrinterUtil.verboseErrorInfo(parser);
		ParseTree tree = parser.doc();
		ParseTreeWalker.DEFAULT.walk(pListener, tree);
		return pListener.agh.getNode();
	}
	
	public static void main(String[] args) throws Exception{
		System.out.println("+++++++");
		CharStream src = new ANTLRFileStream(args[0], "utf-8");
		DoccommentLexer lexer = new DoccommentLexer(src);
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		DoccommentParser parser = new DoccommentParser(tokens);
		DoccommentParserListener pListener = new DoccommentParserListener(tokens, src);
		TreePrinterUtil.verboseErrorInfo(parser);
		ParseTree tree = parser.doc();
		System.out.println(TreePrinterUtil.stringifyTree(tree, parser));
		
		ParseTreeWalker.DEFAULT.walk(pListener, tree);
		pListener.agh.getNode().setName(args[0]);
		System.out.println(pListener.agh.getNode().toString());
	}
}
