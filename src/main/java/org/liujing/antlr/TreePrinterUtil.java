package org.liujing.antlr.parser;

import java.util.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;
import org.antlr.v4.runtime.misc.Interval;

public class TreePrinterUtil{
	
	public static String allText(CharStream sourceStream, Token start, Token stop){
		return sourceStream.getText(new Interval(start.getStartIndex(), stop.getStopIndex()));
	}
	
	public static String stringifyTree(ParseTree tree, Parser parser){
		TreePrinterListener listener = new TreePrinterListener(parser);
		ParseTreeWalker.DEFAULT.walk(listener, tree);
		String formatted = listener.toString();
		return formatted;
	}

	private static String escapeWhitespace(String s, boolean yes){
		return s;
	}
	
	public static String getRuleName(Parser parser, ParserRuleContext ctx){
		return parser.getRuleNames()[ctx.getRuleIndex()];
	}
	
	public static void verboseErrorInfo(Parser parser){
		parser.removeErrorListeners(); // remove ConsoleErrorListener 
		parser.addErrorListener(new VerboseListener()); // add ours
	}
	
	 protected static class TreePrinterListener implements ParseTreeListener {
		private final List<String> ruleNames;
		private final StringBuilder builder = new StringBuilder();
		private int indent = 0;
	
		public TreePrinterListener(Parser parser) {
			this.ruleNames = Arrays.asList(parser.getRuleNames());
		}
	
		public TreePrinterListener(List<String> ruleNames) {
			this.ruleNames = ruleNames;
		}
	
		@Override
		public void visitTerminal(TerminalNode node) {
			if (builder.length() > 0) {
				builder.append(' ');
			}
	
			builder.append(escapeWhitespace(Trees.getNodeText(node, ruleNames), false));
		}
	
		@Override
		public void visitErrorNode(ErrorNode node) {
			if (builder.length() > 0) {
				builder.append(" ");
			}
			builder.append("<error: ");
			builder.append(escapeWhitespace(Trees.getNodeText(node, ruleNames), false));
			builder.append(" >");
		}
	
		@Override
		public void enterEveryRule(ParserRuleContext ctx) {
			if (builder.length() > 0) {
				builder.append('\n');
				if(indent > 0){
					
					for(int i = indent - 1; i >= 0; i --)
						builder.append(" | ");
					builder.append(" + ");
				}
			}
	
			//if (ctx.getChildCount() > 0) {
			//	builder.append('( ');
			//}
	
			int ruleIndex = ctx.getRuleIndex();
			String ruleName;
			if (ruleIndex >= 0 && ruleIndex < ruleNames.size()) {
				ruleName = ruleNames.get(ruleIndex);
			}
			else {
				ruleName = Integer.toString(ruleIndex);
			}
	
			builder.append(ruleName);
			
			Token positionToken = ctx.getStart();
			if (positionToken != null) {
				builder.append(" [line ");
				builder.append(positionToken.getLine());
				builder.append(", pos ");
				builder.append(positionToken.getCharPositionInLine());
				//builder.append(':');
				//builder.append(positionToken.getStopIndex());
				builder.append("]");
			}
			//else {
			//	builder.append('\n');
			//}
			indent ++;
		}
	
		@Override
		public void exitEveryRule(ParserRuleContext ctx) {
			indent --;
			/* if (ctx.getChildCount() > 0) {
				builder.append('\n');
				for(int i = 0; i < indent; i ++)
					builder.append("  ");
				builder.append(")");
			} */
			
		}
	
		@Override
		public String toString() {
			return builder.toString();
		}
	}
	
	public static class VerboseListener extends BaseErrorListener { 
		@Override
		public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol,
			int line, int charPositionInLine, String msg, RecognitionException e)
		{
			List<String> stack = ((Parser)recognizer).getRuleInvocationStack(); Collections.reverse(stack);
			System.err.println("rule stack: "+stack);
			System.err.println("line "+line+":"+charPositionInLine+" at "+
			offendingSymbol+": "+msg);
		} 
	}
}
