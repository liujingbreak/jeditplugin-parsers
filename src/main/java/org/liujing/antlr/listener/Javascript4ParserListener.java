package org.liujing.antlr.parser;

import org.liujing.ironsword.grammar.*;
import java.util.*;
import org.liujing.antlr.parser.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;
import java.io.*;

public class Javascript4ParserListener extends Javascript4BaseListener{
	private Antlr4GrammarHandler agh = new Antlr4GrammarHandler();
	
	private BufferedTokenStream tokenStream;
	private LinkedList<Map<String, Object>> closures = new LinkedList();
	private LinkedList< Object > stack = new LinkedList();
	
	private ParseTreeProperty<Object> treeValues = new ParseTreeProperty();
	/** evaludated value from rule*/
	private Object evalValue;
	
	public Javascript4ParserListener(BufferedTokenStream tokens){
		tokenStream = tokens;
	}
	
	protected void addDocNode(Token t){
		int i = t.getTokenIndex();
		List<Token> tlist = tokenStream.getHiddenTokensToLeft(i, Javascript4Parser.DOC_CHANN);
		if( tlist != null && tlist.size() > 0){
			CommonToken doct = (CommonToken) tlist.get(0);
			agh.addNode("doc", doct.getText(), doct, doct);
		}
	}
	
	@Override public void enterFunctionExpression( Javascript4Parser.FunctionExpressionContext ctx) {
		closures.push(new HashMap<String, Object>());
		agh.enterRule("func", ctx);
		TerminalNode nameNode = ctx.IDENTIFIER();
		agh.setName(nameNode != null ? nameNode.getText() : "");
	}

	@Override public void exitFunctionExpression( Javascript4Parser.FunctionExpressionContext ctx) {
		closures.pop();
		treeValues.put(ctx, agh.getNode());
		agh.exitRule(ctx);
		
	}
	
	@Override public void exitLiteral( Javascript4Parser.LiteralContext ctx) {
		
		Object node = treeValues.removeFrom(ctx.functionExpression());
		if(node != null)
			treeValues.put(ctx, node);
	}

	@Override
	public void exitVariableDeclarator(Javascript4Parser.VariableDeclaratorContext ctx){
		String name = ctx.IDENTIFIER().getText();
		//ctx.variableInitializer()
	}
	@Override
	public void exitExpression(Javascript4Parser.ExpressionContext ctx){
		
	}
	@Override public void exitPrimaryPrefix( Javascript4Parser.PrimaryPrefixContext ctx) {
		ParserRuleContext lit = ctx.literal();
		Object ret = null;
		if(lit != null){
			ret = treeValues.removeFrom(lit);
		}else if(ctx.name() == null){
			ret = treeValues.removeFrom(ctx.name());
		}
		treeValues.put(ctx, ret);
	}

	@Override
	public void exitPrimaryExpression(Javascript4Parser.PrimaryExpressionContext ctx){
		List<Javascript4Parser.PrimarySuffixContext> suffix = ctx.primarySuffix();
		Object ret = treeValues.removeFrom(ctx.primaryPrefix());
		if(suffix != null && suffix.size() > 0 && evalValue != null){
			// other cases
		}else{
			treeValues.put(ctx, ret);
		}
	}
	
	public static void main(String[] args) throws Exception{
		System.out.println("+++++++");
		Javascript4Lexer lexer = new Javascript4Lexer(new ANTLRFileStream(args[0], "utf-8"));
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		Javascript4Parser parser = new Javascript4Parser(tokens);
		Javascript4ParserListener pListener = new Javascript4ParserListener(tokens);
		TreePrinterUtil.verboseErrorInfo(parser);
		ParseTree tree = parser.program();
		//System.out.println(" -----start------ debug parse tree ------------");
		//System.out.println(TreePrinterUtil.stringifyTree(tree, parser));
		//System.out.println(" ------end----- debug parse tree ------------");
		ParseTreeWalker.DEFAULT.walk(pListener, tree);
		pListener.agh.getNode().setName(args[0]);
		System.out.println(pListener.agh.getNode().toString());
	}
}
