package org.liujing.antlr.parser;

import java.util.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

public class TreePrinterUtil{
	public static String stringifyTree(ParseTree tree, Parser parser){
		TreePrinterListener listener = new TreePrinterListener(parser);
		ParseTreeWalker.DEFAULT.walk(listener, tree);
		String formatted = listener.toString();
		return formatted;
	}

	private static String escapeWhitespace(String s, boolean yes){
		return s;
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
				builder.append(' ');
			}
	
			builder.append(escapeWhitespace(Trees.getNodeText(node, ruleNames), false));
		}
	
		@Override
		public void enterEveryRule(ParserRuleContext ctx) {
			if (builder.length() > 0) {
				builder.append('\n');
				for(int i = 0; i < indent; i ++)
					builder.append(" | ");
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
}
