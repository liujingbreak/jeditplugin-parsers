parser grammar Javascript4Parser;
options { tokenVocab=Javascript4Lexer; }
@parser::header {
package org.liujing.antlr.parser;

import java.util.logging.*;
import java.io.*;
}
@parser::members {
    static Logger log = Logger.getLogger(Javascript4Parser.class.getName());
    public static final int DOC_CHANN = 3;
}


program
    : L* blockbody? EOF;

innerScript:
    L* ('<' '!' '--' L*)?  (blockStatement L*)* ('--' '>' L*)? end=scriptEndingTag;

blockStatement
    :  localVariableDeclaration L* (';' L*)*
    | statement L* (';' L*)*
    ;

localVariableDeclaration
    :
    'var' L* variableDeclarator ( L* ',' L* variableDeclarator)*;

statement 

:
    labelledStatement
    | block
    | ifStatement                                  // | ('if')=>ifStatement
    | withStatement                               // | ('with')=>withStatement
    | switchStatement                           // | ('switch')=>switchStatement
    | whileStatement                             // | ('while')=>whileStatement
    | doStatement  //(L* ';')?                                // | ('do')=>doStatement
    | forStatement                                 // | ('for')=>forStatement
    | breakStatement  //(L* ';')?                       // | ('break')=>breakStatement
    | continueStatement  //(L* ';')?                     // | ('continue')=>continueStatement
    | returnStatement //(L* ';')?                         // | ('return')=>returnStatement
    | throwStatement //(L* ';')?                            // | ('throw')=>throwStatement
    | tryStatement                                 // | ('try')=>tryStatement
    | expression //(L* ';')?
    ;
statementExpression:
    multiplicativeExpression ( L* optsNoIn L* multiplicativeExpression)* ('++'|'--'|L* assignmentOperator L* expression)?
;

returnStatement: 'return' (expression)?;
tryStatement: 'try' L* block
  ( L* 'catch' L* '(' L* IDENTIFIER L* ')' L* block)*
  ( L* 'finally' L* block )?;
throwStatement: 'throw' L* expression ;
breakStatement: 'break' (IDENTIFIER)? ;
continueStatement: 'continue' (IDENTIFIER)? ;
whileStatement: 'while' L* '(' L* expression L* ')' L* blockStatement;
doStatement: 'do' L* blockStatement L* 'while' L* '(' L* expression L* ')';
forStatement: 'for' L* '(' L*
                            ( (VAR L*)? IDENTIFIER L* 'in' L* expression
                            | (forInit L*)? ';' L* (expression L*)? ';' L* (forUpdate L*)?
                            )
              ')' L* blockStatement;
forInit: localVariableDeclaration
    | statementExpressionList
    ;
forUpdate
    //@after{log.info("forupdate: "+ $forUpdate.stop);}
    : statementExpressionList ;
statementExpressionList: statementExpression (L* ',' L* statementExpression)*;
//emptyStatement: ;
labelledStatement: IDENTIFIER L* ':' L* blockStatement;
block
    : '{' L* blockbody?'}'
    
    ;
blockbody:
	blockStatement+
	;
preIncrementExpression
    : '++' primaryExpression 
    ;
preDecrementExpression
    : '--' primaryExpression
    ;
primaryExpression
    : primaryPrefix ( L* primarySuffix)*;
primaryPrefix: literal
    | '(' L* expression L* ')'
    | allocationExpression
    | name;
primarySuffix:
     '[' L* expression L* ']'
    | '.' L* IDENTIFIER
    | arguments ;
name: (IDENTIFIER|'this') ( L* '.' L* IDENTIFIER )*;
assignmentOperator:  '/' '=' | '=' | '*=' | '%=' | '+=' | '-=' | '<<=' | '>>=' | '>>>=' | '&=' | '^=' | '|=';

expression
    : conditionalExpression  ( L* assignmentOperator L* expression )?
    ;

arguments: '(' L* (argumentList L*)? ')';
allocationExpression: 'new' L* primaryExpression;
argumentList: expression ( L* ',' L* expression )*;
postfixExpression
    //@after{
    //    $type = $p.type;
    //    $value = $p.value;
    //}
    : p=primaryExpression
    ('++'|'--')?
    ;

conditionalExpression
    : conditionalOrExpression
    ( L* '?' L* exp=expression
    L* ':' L* expression )?
    ;

conditionalOrExpression
    : m=multiplicativeExpression
    ( L* opts L* multiplicativeExpression)*;

opts: ( '||'|'&&'|'|'|'^'|'&'|'==' | '!='|'==='|'in' |'!=='|'instanceof'|'<'|'>'|'<='|'>='|'<<'|'>>'|'>>>'|'+'|'-' );
optsNoIn: ( '||'|'&&'|'|'|'^'|'&'|'==' | '!='|'==='|'!=='|'instanceof'|'<'|'>'|'<='|'>='|'<<'|'>>'|'>>>'|'+'|'-' );

multiplicativeExpression
    : u=unaryExpression
    (  L* ( '*' | '/' | '%' ) L*  unaryExpression )*;

unaryExpression
    :
     ( '+' | '-' ) L* unaryExpression		#addUnaryExp
    | 'typeof' L* unaryExpression		#minusUnaryExp
    | 'void' L* unaryExpression			#voidUnaryExp
    | 'delete' L* unaryExpression		#delUnaryExp
    | preIncrementExpression			#preIncreUnaryExp     
    | preDecrementExpression          	#preDecUnaryExp
    | unaryExpressionNotPlusMinus     	#notPlusUnaryExp
    ;
unaryExpressionNotPlusMinus
    :
    ( '~' | '!' ) L* unaryExpression
    | postfixExpression
    ;

variableDeclarator
    : IDENTIFIER (L* '=' L* exp=variableInitializer)?
    ;

variableInitializer
    :
    expression;

literal
    : DECIMAL_LITERAL
    |HEX_INTEGER_LITERAL
    |STRING_LITERAL
    |BOOLEAN_LITERAL
    |NULL_LITERAL
    |functionExpression
    |jsonExpression
    |Regex
    ;
//regularExp
//    : '/' ( (~('/' | '\\'))		{ System.out.print("1");}
//    		| '\\' '/'       { System.out.print("2");}
//    		//| '\\' '\\'	{ System.out.print("3");}
//    		//| '\\'	{ System.out.print("4");}
//    	)+
//    	'/' ( {getCurrentToken().getText().matches("[gim]+")}? IDENTIFIER)?
//    ;
functionExpression
	//@after{
	//    if(handler != null)
	//	    handler.onFunctionEnd(((CommonToken)$functionExpression.stop).getStopIndex()+1);
	//}
	: f='function' L* (IDENTIFIER L*)?
    		'(' L* ( para=formalParameterList L* )? ')'
    		/* {
    		  if(handler != null) handler.onFunctionStart($f.getLine(),
    		  $funcName!=null?$funcName.getText():"<func>",
    		  $para.tree !=null? joinPlainNodesString($para.tree): "",
    		  ((CommonToken)$functionExpression.start).getStartIndex());
    		} */
    		L* block
	;


formalParameterList: IDENTIFIER (L* ',' L* IDENTIFIER)*;
jsonExpression: objectLiteral
                | arrayLiteral;

objectLiteral
    /* @init{ if(handler != null) handler.onJSONStart(((CommonToken)$objectLiteral.start).getLine(), ((CommonToken)$objectLiteral.start).getStartIndex());
    }
    @after{
        if(handler != null)
            handler.onJSONEnd(((CommonToken)$objectLiteral.stop).getStopIndex()+1);
    } */
    : s='{'
    L* ( propertyNameAndValueList L*)? '}';

propertyNameAndValueList:
    (propertyNameAndValue | ',') ( L* ',' ( L* propertyNameAndValue)? )* ;

    //((L* ',')=> L* ',' (options{k=2;}: L* propertyNameAndValue)? )+;
propertyNameAndValue
    :
    ( IDENTIFIER| STRING_LITERAL | DECIMAL_LITERAL | HEX_INTEGER_LITERAL)
    L* ':' L* conditionalExpression
    ;
arrayLiteral: '[' L* (arrayItems L*)? ']';
arrayItems: (','| expression) ( L* ',' ( L* expression )? )* ;

ifStatement: 'if' L* '(' L* ex=expression  L* rb=')'
    L*  blockStatement ( 'else' L* blockStatement )? ;
withStatement: 'with' L* '(' L* expression L* ')' L* blockStatement ;
switchStatement: 'switch' L* '(' L* expression L* ')' L* '{' L*
    ( switchLabel L* (blockStatement L*)* )* '}';
switchLabel: 'case' L* expression L* ':'
    | 'default' L* ':';

sLASHASSIGN: '/' '='
	;
scriptEndingTag: ret='<' '/' IDENTIFIER '>' 
	;
