package org.liujing.ironsword.grammar;

import java.util.*;
import java.util.logging.*;
import java.io.*;
import org.antlr.v4.runtime.*;

public class Antlr4GrammarNode extends GrammarNode{
    public Antlr4GrammarNode(){
        
    }
    
    public Antlr4GrammarNode(String type, String name){
        super(type, name);
    }
    
    public void setStart(Token tk){
        CommonToken ct = (CommonToken)tk;
        setStartLine(ct.getLine());
        setStartOffset(ct.getStartIndex());
    }
    
    public void setStop(Token tk){
        CommonToken ct = (CommonToken)tk;
        setEndLine(ct.getLine());
        setEndOffset(ct.getStopIndex()+ 1);
    }
}
