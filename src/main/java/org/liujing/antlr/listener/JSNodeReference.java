package org.liujing.antlr.parser;

import java.util.*;
import org.liujing.ironsword.grammar.*;

public class JSNodeReference{
	public JSType type = JSType.UNDEFINED;
	
	public String name;
	
	public GrammarNode gnode;
	
	public JSNodeReference(){
		
	}
	
	public JSNodeReference(GrammarNode gnode){
		this.gnode = gnode;
	}
	
	public JSNodeReference(String name, GrammarNode gnode){
		this.gnode = gnode;
		this.name = name;
	}
	
	public String getName(){
		if(name == null && gnode != null)
			return gnode.getName();
		return name;
	}
	
	public enum JSType{
		STRING,
		NUMBER,
		BOOLEAN,
		ARRAY,
		OBJECT,
		NULL,
		UNDEFINED
	}
}
