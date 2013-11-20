package org.liujing.antlr.parser;

import org.liujing.ironsword.grammar.*;
import java.util.*;
import org.liujing.antlr.parser.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;
import java.io.*;

public class Javascript4ParserHandler extends Javascript4ParserBaseListener{
	
	private Antlr4GrammarHandler agh = new Antlr4GrammarHandler();
	
	private BufferedTokenStream tokenStream;
	private LinkedList<Map<String, Object>> closures = new LinkedList();
	private LinkedList< Map<String, Object> > stack = new LinkedList();
	
	private ParseTreeProperty<Object> treeValues = new ParseTreeProperty();
	/** evaludated value from rule*/
	private Object evalValue;
	
	public Javascript4ParserHandler(BufferedTokenStream tokens){
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
	
	@Override
	public void enterProgram(Javascript4Parser.ProgramContext ctx){
		agh.enterRule("javascript", ctx);
	}
	
	@Override
	public void exitProgram(Javascript4Parser.ProgramContext ctx){
		agh.exitRule(ctx);
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
		Map<String, Object> values = stack.peekFirst();
		if(values != null){
			values.put("primary", agh.getNode());
		}
	}
	
	@Override public void exitVariableDeclarator(Javascript4Parser.VariableDeclaratorContext ctx){
		String name = ctx.IDENTIFIER().getText();
		if(ctx.exp != null){
			Object right = treeValues.removeFrom(ctx.exp);
			if(right != null && right instanceof Antlr4GrammarNode){
				((Antlr4GrammarNode)right).setName(name);
			}
		}
	}
	
	@Override public void exitVariableInitializer(Javascript4Parser.VariableInitializerContext ctx){
		Object right = treeValues.removeFrom(ctx.expression());
		if(right instanceof Antlr4GrammarNode){
			treeValues.put(ctx, right);
		}
	}
	
	@Override public void exitLiteral( Javascript4Parser.LiteralContext ctx) {
		
		Object node = treeValues.removeFrom(ctx.functionExpression());
		if(node != null){
			stack.peekFirst().put("primary", node);
			//treeValues.put(ctx, node);
		}
	}

	@Override
	public void enterExpression(Javascript4Parser.ExpressionContext ctx){
		stack.push(new HashMap<String, Object>());
	}
	
	@Override
	public void exitExpression(Javascript4Parser.ExpressionContext ctx){
		Map<String, Object> values = stack.pop();
		Object lValue = values.get("primary");
		
		Javascript4Parser.ExpressionContext right = ctx.expression();
		if(right != null){
			Object rValue = treeValues.removeFrom(right);

			if( rValue instanceof Antlr4GrammarNode && lValue instanceof String){

				Antlr4GrammarNode node = (Antlr4GrammarNode) rValue;
				node.setName((String)lValue);
				treeValues.put(ctx, rValue);
			}
		}else{
			treeValues.put(ctx, lValue);
		}
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
		Map<String, Object> values = stack.peekFirst();
		Object v = values.get("primary");
		if(v != null && v instanceof Antlr4GrammarNode){
			List<Javascript4Parser.PrimarySuffixContext> suffix = ctx.primarySuffix();
			if(suffix != null && suffix.size() > 0 && evalValue != null){
				values.remove("primary");
			}
		}else{
			values.put("primary", ctx.getText());
		}
	}
	
	public static void main(String[] args) throws Exception{
		System.out.println("+++++++");
		Javascript4Lexer lexer = new Javascript4Lexer(new ANTLRFileStream(args[0], "utf-8"));
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		Javascript4Parser parser = new Javascript4Parser(tokens);
		Javascript4ParserHandler pListener = new Javascript4ParserHandler(tokens);
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
