package org.liujing.ironsword.grammar;

import java.util.*;
import java.util.logging.*;
import java.io.*;
import org.antlr.v4.runtime.*;

public class Antlr4GrammarHandler{
    private static Logger log = Logger.getLogger(Antlr4GrammarHandler.class.getName());
    protected Antlr4GrammarNode node;
    protected LinkedList<String> scopeStack = new LinkedList();
    public final static String NO_NAME = "No Name";
    
    public Antlr4GrammarHandler(){
      
    }
    
    public void addNode(String type, String name,Token startTk, Token stopTk){
        addNode(0, type, name, startTk, stopTk);
    }
    /**  addNode with channel setting
     @param channel channel number
     @param type type
     @param name name
     @param startTk start token
     @param stopTk stop token
    */
    public void addNode(int channel, String type, String name, Token startTk, Token stopTk){
       Antlr4GrammarNode subNode = new Antlr4GrammarNode(type, name);
       //subNode.setChannel(channel);
       subNode.setStart(startTk);
       subNode.setStop(stopTk);
       if(node != null)
         node.addChild(subNode);
       
    }
    
    /** for ANTLR4 listener*/
    public void enterRule(String type, ParserRuleContext ctx){
    	onRuleStart(type, ctx.getStart());
    }
    
    /** for ANTLR4 listener*/
    public void exitRule(ParserRuleContext ctx){
    	onRuleStop(ctx.getStop());
    }
    
    public void onRuleStart(String type, Token startTk){
      Antlr4GrammarNode subNode = new Antlr4GrammarNode();
      subNode.setType(type);
      if(node != null)
        node.addChild(subNode);
      node = subNode;
      node.setStart(startTk);
      node.setName(NO_NAME);
    }
    public void onRuleStop(Token stopTk){
        node.setStop(stopTk);
        if(node.getParent() != null)
            node = (Antlr4GrammarNode)node.getParent();
    }
    
    
    public void onRuleStart(int channel, String type){
      Antlr4GrammarNode subNode = new Antlr4GrammarNode();
      //subNode.setChannel(channel);
      subNode.setType(type);
      if(node != null)
        node.addChild(subNode);
      node = subNode;
      node.setName(NO_NAME);
    }
    public void onRuleStart(String type){
        onRuleStart(0, type);
    }
    public void onRuleStop(Token startTk, Token stopTk){
        node.setStart(startTk);
        node.setStop(stopTk);
        if(node.getParent() != null)
            node = (Antlr4GrammarNode)node.getParent();
    }
    
    public boolean onRuleStartByParent(String type, String parentType){
        if(node != null && node.getType().equals(parentType)){
            onRuleStart(type);
            return true;
        }
        return false;
    }
    
    public Antlr4GrammarNode currentNode(){
        return node;
    }
    
    public Antlr4GrammarNode getNode(){
        return node;
    }
    
    public boolean isType(String type){
        return node.getType().equals(type);
    }
    
    public void setName(String name){
        node.setName(name);
    }
    
    public boolean isParentType(String type){
        if(node.getParent() == null){
            return type == null;
        }else{
            return node.getParent().getType().equals(type);
        }
    }
    
    public boolean onRuleStopByParent(Token startTk, Token stopTk, String parentType){
        if(node.getParent() != null && node.getParent().getType().equals(parentType)){
            onRuleStop(startTk, stopTk);
            return true;
        }
        return false;
    }
    
    /**
    help to create a stack based scope concept
    */
    public void scopeStart(String scopeName){
        scopeStack.add(scopeName);
    }
    
    public String scopeEnd(){
        return scopeStack.removeLast();
    }
    
    public boolean isScope(String scope){
        String s = scopeStack.peekLast();
        return s != null && s.equals(scope);
    }
    
    public boolean inScope(String scope){
        Iterator<String> it = scopeStack.descendingIterator();
        while(it.hasNext()){
            if(it.next().equals(scope))
                return true;
        }
        return false;
    }
    
    public void printTree(){
        node.travelTree(0, System.out);
    }
}
