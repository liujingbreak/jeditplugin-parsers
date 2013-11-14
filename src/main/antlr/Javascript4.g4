grammar Javascript4;

@header {
package org.liujing.antlr.parser;

import java.util.logging.*;
import java.io.*;
}
@members {
    static Logger log = Logger.getLogger(Javascript4Parser.class.getName());
    public static final int DOC_CHANN = 3;
}

program
    : L* blockbody? EOF;

innerScript:
    L* ('<' '!' '--' L*)?  (blockStatement L*)* ('--' '>' L*)? end=scriptEndingTag;

blockStatement
    /* @init{
        addDocNode($start);
    } */:  localVariableDeclaration
    | statement ;

localVariableDeclaration
    :
    'var' L* variableDeclarator ( L* ',' L* variableDeclarator)*;

statement 

:
    labelledStatement
    | block
    //| emptyStatement                                // | (';')=>emptyStatement
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
	( blockStatement L* (';' L*)* )+
	;
preIncrementExpression returns[String type, Object value]
    : '++' primaryExpression 
    ;
preDecrementExpression returns[String type, Object value]
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
    /* @after{
        if(handler != null){
            if(exp != null && ((CommonTree)$exp.tree).getToken()!= null &&
                FUNCTION ==((CommonTree)$exp.tree).getToken().getType())
                handler.onFunctionAssign( ((CommonTree)$varid.tree).getToken().getText(),
                $exp.tree);
        }
    } */
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
    |regularExp
    ;
regularExp
    : slash='/' ( ~('/' | '\\')
    		| '\\' '/' 
    		| '\\' '\\'
    		| '\\'
    	)*
    	'/' ( {getCurrentToken().getText().matches("[gim]+")}? IDENTIFIER)?
    ;
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
    //@init{
    //    addDocNode($start);
    //}
    //@after{
    //    if(handler != null && ((CommonTree)$exp.tree).getToken() != null
    //        && ((CommonTree)$exp.tree).getToken().getType() == FUNCTION)
    //
    //        handler.onJSONProperty($id.text, $id.getLine());
    //}
    :
    (id=IDENTIFIER|id=STRING_LITERAL | id=DECIMAL_LITERAL | id=HEX_INTEGER_LITERAL)
    L* ':' L* exp=conditionalExpression
    ;
arrayLiteral: '[' L* (arrayItems L*)? ']';
arrayItems: (','| expression) ( L* ',' ( L* expression )? )* ;

ifStatement: 'if' L* '(' L* ex=expression  L* rb=')'
    L*  blockStatement ( L* (';' L*)? 'else' L* blockStatement )? ;
withStatement: 'with' L* '(' L* expression L* ')' L* blockStatement ;
switchStatement: 'switch' L* '(' L* expression L* ')' L* '{' L*
    ( switchLabel L* (blockStatement L*)* )* '}';
switchLabel: 'case' L* expression L* ':'
    | 'default' L* ':';

L: ('\n'|'\r'|'\u2028'|'\u2029')+;
SLASH:'/';
sLASHASSIGN: '/' '=';
BREAK: 'break';
CONTINUE: 'continue';
DELETE: 'delete';
ELSE: 'else';
FOR: 'for';
FUNCTION: 'function';
IF: 'if';
IN: 'in';
NEW: 'new';
RETURN: 'return';
THIS: 'this';
TYPEOF: 'typeof';
VAR: 'var';
VOID: 'void';
WHILE: 'while';
WITH: 'with';
CASE: 'case';
CATCH: 'catch';
CLASS: 'class';
CONST: 'const';
DEBUGGER: 'debugger';
DEFAULT: 'default';
DO: 'do';
ENUM: 'enum';
EXPORT: 'export';
EXTENDS: 'extends';
FINALLY: 'finally';
IMPORT: 'import';
SUPER: 'super';
SWITCH: 'switch';
THROW: 'throw';
TRY: 'try';
LBRACE: '{';
RBRACE: '}';
LPAREN: '(';
RPAREN: ')';
LBRACKET: '[';
RBRACKET: ']';
DOT: '.';
SEMICOLON: ';';
COMMA: ',';
LT: '<';
GT: '>';
LE: '<=';
GE: '>=';
EQ: '==';
NE: '!=';
SEQ: '===';
SNEQ: '!==';
PLUS: '+';
MINUS: '-';
STAR: '*';
REM: '%';
INCR: '++';
DECR: '--';
LSHIFT: '<<';
RSHIFT: '>>';
RUNSHIFT: '>>>';
BIT_AND: '&';
BIT_OR: '|';
XOR: '^';
BANG: '!';
TILDE: '~';
SC_AND: '&&';
SC_OR: '||';
HOOK: '?';
COLON: ':';
ASSIGN: '=';
PLUSASSIGN: '+=';
MINUSASSIGN: '-=';
STARASSIGN: '*=';
REMASSIGN: '%=';
LSHIFTASSIGN: '<<=';
RSIGNEDSHIFTASSIGN: '>>=';
RUNSIGNEDSHIFTASSIGN: '>>>=';
ANDASSIGN: '&=';
ORASSIGN: '|=';
XORASSIGN: '^=';
INTANCE_OF: 'instanceof';
DECIMAL_LITERAL: DECIMAL_INTEGER_LITERAL '.' DECIMAL_DIGITS?
    | '.' DECIMAL_DIGITS EXPONENT_PART?
    | DECIMAL_INTEGER_LITERAL EXPONENT_PART? ;

fragment DECIMAL_INTEGER_LITERAL: '0'| NON_ZERO_DIGIT DECIMAL_DIGITS?;
fragment NON_ZERO_DIGIT: '1'..'9';
fragment EXPONENT_PART: ('e' | 'E') ('+'|'-')? DECIMAL_DIGITS;
HEX_INTEGER_LITERAL:('0x'|'0X') HEX_DIGIT+;
fragment DECIMAL_DIGITS: DECIMAL_DIGIT+;
fragment DECIMAL_DIGIT: '0'..'9';
fragment HEX_ESCAPE_SEQUENCE: 'x' HEX_DIGIT HEX_DIGIT;
fragment HEX_DIGIT: ('0'..'9'| 'a'..'f' | 'A'..'F');

NULL_LITERAL: 'null';
BOOLEAN_LITERAL: 'true'|'false';
STRING_LITERAL: (
    '"' DOUBLE_STRING_CHARACTERS '"'
    | '\'' SINGLE_STRING_CHARACTERS '\'');
fragment DOUBLE_STRING_CHARACTERS: (~('"'|'\\'|'\n'|'\r'|'\u2028'|'\u2029')
        | '\\' ~('\n'|'\r'|'\u2028'|'\u2029'))*;
fragment SINGLE_STRING_CHARACTERS:(~('\''|'\\'|'\n'|'\r'|'\u2028'|'\u2029')
        | '\\' ~('\n'|'\r'|'\u2028'|'\u2029'))*;

fragment UNICODE_ESCAPE_SEQUENCE: 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT;

IDENTIFIER: IDENTIFIER_START (IDENTIFIER_PART)*;
fragment IDENTIFIER_START: '$'|'_'|UNICODE_LETTER;
fragment IDENTIFIER_PART:
    (IDENTIFIER_START|UNICODE_DIGIT);
fragment UNICODE_LETTER:
        'A'..'Z'
        | 'a'..'z'
        | '\u00aa'
        | '\u00b5'
        | '\u00ba'
        | '\u00c0'..'\u00d6'
        | '\u00d8'..'\u00f6'
        | '\u00f8'..'\u021f'
        | '\u0222'..'\u0233'
        | '\u0250'..'\u02ad'
        | '\u02b0'..'\u02b8'
        | '\u02bb'..'\u02c1'
        | '\u02d0'..'\u02d1'
        | '\u02e0'..'\u02e4'
        | '\u02ee'
        | '\u037a'
        | '\u0386'
        | '\u0388'..'\u038a'
        | '\u038c'
        | '\u038e'..'\u03a1'
        | '\u03a3'..'\u03ce'
        | '\u03d0'..'\u03d7'
        | '\u03da'..'\u03f3'
        | '\u0400'..'\u0481'
        | '\u048c'..'\u04c4'
        | '\u04c7'..'\u04c8'
        | '\u04cb'..'\u04cc'
        | '\u04d0'..'\u04f5'
        | '\u04f8'..'\u04f9'
        | '\u0531'..'\u0556'
        | '\u0559'
        | '\u0561'..'\u0587'
        | '\u05d0'..'\u05ea'
        | '\u05f0'..'\u05f2'
        | '\u0621'..'\u063a'
        | '\u0640'..'\u064a'
        | '\u0671'..'\u06d3'
        | '\u06d5'
        | '\u06e5'..'\u06e6'
        | '\u06fa'..'\u06fc'
        | '\u0710'
        | '\u0712'..'\u072c'
        | '\u0780'..'\u07a5'
        | '\u0905'..'\u0939'
        | '\u093d'
        | '\u0950'
        | '\u0958'..'\u0961'
        | '\u0985'..'\u098c'
        | '\u098f'..'\u0990'
        | '\u0993'..'\u09a8'
        | '\u09aa'..'\u09b0'
        | '\u09b2'
        | '\u09b6'..'\u09b9'
        | '\u09dc'..'\u09dd'
        | '\u09df'..'\u09e1'
        | '\u09f0'..'\u09f1'
        | '\u0a05'..'\u0a0a'
        | '\u0a0f'..'\u0a10'
        | '\u0a13'..'\u0a28'
        | '\u0a2a'..'\u0a30'
        | '\u0a32'..'\u0a33'
        | '\u0a35'..'\u0a36'
        | '\u0a38'..'\u0a39'
        | '\u0a59'..'\u0a5c'
        | '\u0a5e'
        | '\u0a72'..'\u0a74'
        | '\u0a85'..'\u0a8b'
        | '\u0a8d'
        | '\u0a8f'..'\u0a91'
        | '\u0a93'..'\u0aa8'
        | '\u0aaa'..'\u0ab0'
        | '\u0ab2'..'\u0ab3'
        | '\u0ab5'..'\u0ab9'
        | '\u0abd'
        | '\u0ad0'
        | '\u0ae0'
        | '\u0b05'..'\u0b0c'
        | '\u0b0f'..'\u0b10'
        | '\u0b13'..'\u0b28'
        | '\u0b2a'..'\u0b30'
        | '\u0b32'..'\u0b33'
        | '\u0b36'..'\u0b39'
        | '\u0b3d'
        | '\u0b5c'..'\u0b5d'
        | '\u0b5f'..'\u0b61'
        | '\u0b85'..'\u0b8a'
        | '\u0b8e'..'\u0b90'
        | '\u0b92'..'\u0b95'
        | '\u0b99'..'\u0b9a'
        | '\u0b9c'
        | '\u0b9e'..'\u0b9f'
        | '\u0ba3'..'\u0ba4'
        | '\u0ba8'..'\u0baa'
        | '\u0bae'..'\u0bb5'
        | '\u0bb7'..'\u0bb9'
        | '\u0c05'..'\u0c0c'
        | '\u0c0e'..'\u0c10'
        | '\u0c12'..'\u0c28'
        | '\u0c2a'..'\u0c33'
        | '\u0c35'..'\u0c39'
        | '\u0c60'..'\u0c61'
        | '\u0c85'..'\u0c8c'
        | '\u0c8e'..'\u0c90'
        | '\u0c92'..'\u0ca8'
        | '\u0caa'..'\u0cb3'
        | '\u0cb5'..'\u0cb9'
        | '\u0cde'
        | '\u0ce0'..'\u0ce1'
        | '\u0d05'..'\u0d0c'
        | '\u0d0e'..'\u0d10'
        | '\u0d12'..'\u0d28'
        | '\u0d2a'..'\u0d39'
        | '\u0d60'..'\u0d61'
        | '\u0d85'..'\u0d96'
        | '\u0d9a'..'\u0db1'
        | '\u0db3'..'\u0dbb'
        | '\u0dbd'
        | '\u0dc0'..'\u0dc6'
        | '\u0e01'..'\u0e30'
        | '\u0e32'..'\u0e33'
        | '\u0e40'..'\u0e46'
        | '\u0e81'..'\u0e82'
        | '\u0e84'
        | '\u0e87'..'\u0e88'
        | '\u0e8a'
        | '\u0e8d'
        | '\u0e94'..'\u0e97'
        | '\u0e99'..'\u0e9f'
        | '\u0ea1'..'\u0ea3'
        | '\u0ea5'
        | '\u0ea7'
        | '\u0eaa'..'\u0eab'
        | '\u0ead'..'\u0eb0'
        | '\u0eb2'..'\u0eb3'
        | '\u0ebd'..'\u0ec4'
        | '\u0ec6'
        | '\u0edc'..'\u0edd'
        | '\u0f00'
        | '\u0f40'..'\u0f6a'
        | '\u0f88'..'\u0f8b'
        | '\u1000'..'\u1021'
        | '\u1023'..'\u1027'
        | '\u1029'..'\u102a'
        | '\u1050'..'\u1055'
        | '\u10a0'..'\u10c5'
        | '\u10d0'..'\u10f6'
        | '\u1100'..'\u1159'
        | '\u115f'..'\u11a2'
        | '\u11a8'..'\u11f9'
        | '\u1200'..'\u1206'
        | '\u1208'..'\u1246'
        | '\u1248'
        | '\u124a'..'\u124d'
        | '\u1250'..'\u1256'
        | '\u1258'
        | '\u125a'..'\u125d'
        | '\u1260'..'\u1286'
        | '\u1288'
        | '\u128a'..'\u128d'
        | '\u1290'..'\u12ae'
        | '\u12b0'
        | '\u12b2'..'\u12b5'
        | '\u12b8'..'\u12be'
        | '\u12c0'
        | '\u12c2'..'\u12c5'
        | '\u12c8'..'\u12ce'
        | '\u12d0'..'\u12d6'
        | '\u12d8'..'\u12ee'
        | '\u12f0'..'\u130e'
        | '\u1310'
        | '\u1312'..'\u1315'
        | '\u1318'..'\u131e'
        | '\u1320'..'\u1346'
        | '\u1348'..'\u135a'
        | '\u13a0'..'\u13b0'
        | '\u13b1'..'\u13f4'
        | '\u1401'..'\u1676'
        | '\u1681'..'\u169a'
        | '\u16a0'..'\u16ea'
        | '\u1780'..'\u17b3'
        | '\u1820'..'\u1877'
        | '\u1880'..'\u18a8'
        | '\u1e00'..'\u1e9b'
        | '\u1ea0'..'\u1ee0'
        | '\u1ee1'..'\u1ef9'
        | '\u1f00'..'\u1f15'
        | '\u1f18'..'\u1f1d'
        | '\u1f20'..'\u1f39'
        | '\u1f3a'..'\u1f45'
        | '\u1f48'..'\u1f4d'
        | '\u1f50'..'\u1f57'
        | '\u1f59'
        | '\u1f5b'
        | '\u1f5d'
        | '\u1f5f'..'\u1f7d'
        | '\u1f80'..'\u1fb4'
        | '\u1fb6'..'\u1fbc'
        | '\u1fbe'
        | '\u1fc2'..'\u1fc4'
        | '\u1fc6'..'\u1fcc'
        | '\u1fd0'..'\u1fd3'
        | '\u1fd6'..'\u1fdb'
        | '\u1fe0'..'\u1fec'
        | '\u1ff2'..'\u1ff4'
        | '\u1ff6'..'\u1ffc'
        | '\u207f'
        | '\u2102'
        | '\u2107'
        | '\u210a'..'\u2113'
        | '\u2115'
        | '\u2119'..'\u211d'
        | '\u2124'
        | '\u2126'
        | '\u2128'
        | '\u212a'..'\u212d'
        | '\u212f'..'\u2131'
        | '\u2133'..'\u2139'
        | '\u2160'..'\u2183'
        | '\u3005'..'\u3007'
        | '\u3021'..'\u3029'
        | '\u3031'..'\u3035'
        | '\u3038'..'\u303a'
        | '\u3041'..'\u3094'
        | '\u309d'..'\u309e'
        | '\u30a1'..'\u30fa'
        | '\u30fc'..'\u30fe'
        | '\u3105'..'\u312c'
        | '\u3131'..'\u318e'
        | '\u31a0'..'\u31b7'
        | '\u3400'
        | '\u4db5'
        | '\u4e00'
        | '\u9fa5'
        | '\ua000'..'\ua48c'
        | '\uac00'
        | '\ud7a3'
        | '\uf900'..'\ufa2d'
        | '\ufb00'..'\ufb06'
        | '\ufb13'..'\ufb17'
        | '\ufb1d'
        | '\ufb1f'..'\ufb28'
        | '\ufb2a'..'\ufb36'
        | '\ufb38'..'\ufb3c'
        | '\ufb3e'
        | '\ufb40'..'\ufb41'
        | '\ufb43'..'\ufb44'
        | '\ufb46'..'\ufbb1'
        | '\ufbd3'..'\ufd3d'
        | '\ufd50'..'\ufd8f'
        | '\ufd92'..'\ufdc7'
        | '\ufdf0'..'\ufdfb'
        | '\ufe70'..'\ufe72'
        | '\ufe74'
        | '\ufe76'..'\ufefc'
        | '\uff21'..'\uff3a'
        | '\uff41'..'\uff5a'
        | '\uff66'..'\uffbe'
        | '\uffc2'..'\uffc7'
        | '\uffca'..'\uffcf'
        | '\uffd2'..'\uffd7'
        | '\uffda'..'\uffdc';

fragment UNICODE_DIGIT:
        '0'..'9'
        | '\u0660'..'\u0669'
        | '\u06f0'..'\u06f9'
        | '\u0966'..'\u096f'
        | '\u09e6'..'\u09ef'
        | '\u0a66'..'\u0a6f'
        | '\u0ae6'..'\u0aef'
        | '\u0b66'..'\u0b6f'
        | '\u0be7'..'\u0bef'
        | '\u0c66'..'\u0c6f'
        | '\u0ce6'..'\u0cef'
        | '\u0d66'..'\u0d6f'
        | '\u0e50'..'\u0e59'
        | '\u0ed0'..'\u0ed9'
        | '\u0f20'..'\u0f29'
        | '\u1040'..'\u1049'
        | '\u1369'..'\u1371'
        | '\u17e0'..'\u17e9'
        | '\u1810'..'\u1819'
        | '\uff10'..'\uff19';

DocComment:
     '/**' .*? '*/' ('\n'|'\r')*  -> channel(DOC_CHANN)
    ;

MultiLineComment
    : '/*' .*? '*/' ('\n'|'\r')* -> skip
    ;
SingleLineComment: '//' (~('\n'|'\r'))* ('\n'|'\r')* 	-> skip;

WHITE_SPACE // Tab, vertical tab, form feed, space, non-breaking space and any other unicode "space separator".
	: ('\t' | '\u000b' | '' |'f'| ' ' | '\u00a0'|USP)	-> skip
	;


scriptEndingTag: ret='</' IDENTIFIER '>' ;

fragment USP: '\u2000'..'\u200b' | '\u3000';
//UTF8Y_HEADER: '\ubbef\u2fbf';
ANYCHAR: .;

